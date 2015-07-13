//
//  MFACityDataParser.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 03.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NTYCSVTable/NTYCSVTable.h>
#import <MagicalRecord/MagicalRecord.h>

#import "NSString+Utils.h"

#import "MFANode.h"
#import "MFACity.h"
#import "MFALine.h"
#import "MFAStation.h"
#import "MFAPortal.h"
#import "MFAInterchange.h"

#import "MFACityDataParser.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                                 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                                  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];


@interface MFACityDataParser ()

@property (nonatomic, copy, readwrite) NSDictionary *cityMetadata;
@property (nonatomic, copy) NSString *csvPath;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation MFACityDataParser

- (instancetype)initWithCityMeta:(NSDictionary *)city pathToCSV:(NSString *)path
            managedObjectContext:(NSManagedObjectContext *)moc delegate:(id<MFACityDataParserDelegate>)delegate
{
    NSParameterAssert(city != nil);
    NSParameterAssert(path != nil);
    NSParameterAssert(moc  != nil);
    
    self = [super init];
    if (self) {
        self.cityMetadata = city;
        self.csvPath = path;
        self.managedObjectContext = moc;
        self.delegate = delegate;
    }
    
    return self;
}

- (NSNumberFormatter *)numberFormatter
{
    if (_numberFormatter == nil) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        f.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        
        _numberFormatter = f;
    }
    
    return _numberFormatter;
}

- (void)start
{
    NSManagedObjectContext *childContext = [NSManagedObjectContext MR_contextWithParent:self.managedObjectContext];
    
    // perform parsing in background
    [childContext performBlock:^{
        MFACity *city = [self parseCityIntoContext:childContext];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (city) {
                [self.delegate cityDataParser:self didFinishParsingCityWithIdentifier:self.cityMetadata[@"path"]];
            }
            else {
                [self.delegate cityDataParserDidFail:self];
            }
        });
    }];
    
}

- (MFACity *)parseSync
{
    // use main context
    return [self parseCityIntoContext:self.managedObjectContext];
}

- (MFACity *)parseCityIntoContext:(NSManagedObjectContext *)context
{
    NSDate *start = [NSDate date];
    
    MFACity *city = [self configureCityInContext:context];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.csvPath error:nil];
    
    NSMutableDictionary *linesCache = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *stationsCache = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *portalsCache = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *nodesCache = [[NSMutableDictionary alloc] init];
    
    files = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject startsWithString:@"lines"] ||
            [evaluatedObject startsWithString:@"portals"] ||
            [evaluatedObject startsWithString:@"stations"] ||
            [evaluatedObject startsWithString:@"interchanges"]) {
            
            return YES;
        }
        
        return NO;
    }]];
    
    id weights = @{
                   @"lines" : @0,
                   @"stations" : @1,
                   @"portals" : @2,
                   @"interchanges" : @3
                   };
    
    id characterSet = [NSCharacterSet characterSetWithCharactersInString:@"_."];
    
    files = [files sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        
        NSString *key1 = [obj1 componentsSeparatedByCharactersInSet:characterSet][0];
        NSString *key2 = [obj2 componentsSeparatedByCharactersInSet:characterSet][0];
        
        NSNumber *rep1 = weights[key1] ?: @0;
        NSNumber *rep2 = weights[key2] ?: @0;
        
        return [rep1 compare:rep2];
    }];
    
    for (NSString *filePath in files) {
        if ([filePath startsWithString:@"lines"]) {
            [self parseLinesFromFile:filePath
                          linesCache:linesCache
                managedObjectContext:context];
        }
        else if ([filePath startsWithString:@"stations"]) {
            [self parseStationsFromFile:filePath
                             linesCache:linesCache
                          stationsCache:stationsCache
                             nodesCache:nodesCache
                   managedObjectContext:context];
        }
        else if ([filePath startsWithString:@"portals"]) {
            [self parsePortalsFromFile:filePath
                         stationsCache:stationsCache
                          portalsCache:portalsCache
                  managedObjectContext:context];
        }
        else if ([filePath startsWithString:@"interchanges"]) {
            [self parseInterchangesFromFile:filePath
                              stationsCache:stationsCache
                       managedObjectContext:context];
        }
    }
    
    for (id key in linesCache) {
        [linesCache[key] setCity:city];
    }
    
    for (id key in stationsCache) {
        [stationsCache[key] setCity:city];
    }
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    
    NSLog(@"%@ Execution Time: %f", NSStringFromSelector(_cmd), executionTime);
    
    [context MR_saveToPersistentStoreAndWait];
    
    return city;
}

- (void)parseInterchangesFromFile:(NSString *)filePath stationsCache:(NSMutableDictionary *)stationsCache managedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *parsedLines = [self parseFileAtURL:[NSURL URLWithString:filePath
                                                       relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    
    for (NSDictionary *interchangeProperties in parsedLines) {
        NSNumber *stationFromId = interchangeProperties[@"station_from"];
        NSNumber *stationToId = interchangeProperties[@"station_to"];
        
        MFAInterchange *interchange = [MFAInterchange insertInManagedObjectContext:context];
        interchange.fromStation = stationsCache[stationFromId];
        interchange.toStation = stationsCache[stationToId];
        
        interchange.maxWidth = interchangeProperties[@"max_width"];
        interchange.minStep = interchangeProperties[@"min_step"];
        interchange.minStepRamp = interchangeProperties[@"min_step_ramp"];
        interchange.elevator = interchangeProperties[@"lift"];
        interchange.elevatorMinusSteps = interchangeProperties[@"lift_minus_step"];
        interchange.minRailWidth = interchangeProperties[@"min_rail_width"];
        interchange.maxRailWidth = interchangeProperties[@"max_rail_width"];
        interchange.maxAngle = interchangeProperties[@"max_angle"];
        interchange.escalator = interchangeProperties[@"escalator"];
    }
}

- (void)parseLinesFromFile:(NSString *)filePath
                linesCache:(NSMutableDictionary *)linesCache
      managedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *parsedLines = [self parseFileAtURL:[NSURL URLWithString:filePath
                                                       relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    
    NSString *lang = [filePath substringWithRange:NSMakeRange(6, 2)];
    
    for (NSDictionary *lineProperties in parsedLines) {
        NSNumber *lineId = lineProperties[@"id_line"];
        
        if (linesCache[lineId] == nil) {
            MFALine *line = [MFALine insertInManagedObjectContext:context];
        
            line.lineId = lineId;
            line.name = @{ lang : lineProperties[@"name"] };
            
            NSScanner *colorScanner = [[NSScanner alloc] initWithString:lineProperties[@"color"]];
            colorScanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"#"];
            
            unsigned int intColor = 0;
            [colorScanner scanHexInt:&intColor];
            
            line.color = UIColorFromRGB(intColor)
            
            linesCache[lineId] = line;
        }
        else {
            MFALine *line = linesCache[lineId];
            NSMutableDictionary *names = [line.name mutableCopy];
            names[lang] = lineProperties[@"name"];
            line.name = [names copy];
        }
    }
}

- (void)parseStationsFromFile:(NSString *)filePath
                   linesCache:(NSMutableDictionary *)linesCache
                stationsCache:(NSMutableDictionary *)stationsCache
                   nodesCache:(NSMutableDictionary *)nodesCache
         managedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *parsedStations = [self parseFileAtURL:[NSURL URLWithString:filePath
                                                          relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    
    NSString *lang = [filePath substringWithRange:NSMakeRange(9, 2)];
    
    for (NSDictionary *stationProperties in parsedStations) {
        NSNumber *stationId = stationProperties[@"id_station"];
        
        if (stationsCache[stationId] == nil) {
            MFAStation *station = [MFAStation insertInManagedObjectContext:context];
            
            station.stationId = stationId;
            
            NSNumber *nodeId = stationProperties[@"id_node"];
            if (nodesCache[nodeId]) {
                station.node = nodesCache[nodeId];
            }
            else {
                MFANode *node = [MFANode insertInManagedObjectContext:context];
                node.nodeId = nodeId;
                station.node = node;
                nodesCache[nodeId] = node;
            }
            
            station.lineId = stationProperties[@"id_line"];
            station.name = @{ lang : stationProperties[@"name"] };
            station.lat = [self.numberFormatter numberFromString:stationProperties[@"lat"]];
            station.lon = [self.numberFormatter numberFromString:stationProperties[@"lon"]];
        
            station.line = linesCache[station.lineId];
            stationsCache[stationId] = station;
        }
        else {
            MFAStation *station = stationsCache[stationId];
            NSMutableDictionary *names = [station.name mutableCopy];
            names[lang] = stationProperties[@"name"];
            station.name = [names copy];
        }
    }
}

- (void)parsePortalsFromFile:(NSString *)filePath
               stationsCache:(NSMutableDictionary *)stationsCache
                portalsCache:(NSMutableDictionary *)portalsCache
        managedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *parsedPortals = [self parseFileAtURL:[NSURL URLWithString:filePath
                                                         relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    
    NSString *lang = [filePath substringWithRange:NSMakeRange(8, 2)];
    
    for (NSDictionary *portalProperties in parsedPortals) {
        NSNumber *portalId = portalProperties[@"id_entrance"];
        
        if (portalsCache[portalId] == nil) {
            MFAPortal *portal = [MFAPortal insertInManagedObjectContext:context];
        
            portal.potralId = portalId;
            portal.portalNumber = portalProperties[@"meetcode"];
            portal.name = @{ lang : portalProperties[@"name"] };
            portal.stationId = portalProperties[@"id_station"];
            //    self.directionValue =
            portal.lat = [self.numberFormatter numberFromString:portalProperties[@"lat"]];
            portal.lon = [self.numberFormatter numberFromString:portalProperties[@"lon"]];
        
            portal.station = stationsCache[portal.stationId];
            portalsCache[portalId] = portal;
        }
        else {
            MFAPortal *portal = portalsCache[portalId];
            NSMutableDictionary *names = [portal.name mutableCopy];
            names[lang] = portalProperties[@"name"];
            portal.name = [names copy];
        }
    }
}

- (MFACity *)configureCityInContext:(NSManagedObjectContext *)context
{
    MFACity *city = [MFACity cityWithIdentifier:self.cityMetadata[@"path"]];
    if (city &&
        ![city.version isEqualToNumber:self.cityMetadata[@"ver"]]) {
        
        // If found city in coredata, but versions does not match, delete stored city and
        // create new from meta
        
        NSLog(@"Found stored city: %@, version: %@", city.name, city.version);
        NSLog(@"Got new meta for city: %@, version: %@", self.cityMetadata[@"name"], self.cityMetadata[@"ver"]);
        
        // Delete the old city object.
        // It will cascade to all info related to this city: stations, lines, portals, etc.
        [context deleteObject:[city MR_inContext:context]];
        
        city = nil;
    }
    
    if (city == nil) {
        // Create new city
        city = [MFACity insertInManagedObjectContext:context];
        
        // Extract names in different languages into Dictionary
        NSMutableDictionary *names = [NSMutableDictionary new];
        for (NSString *key in self.cityMetadata.allKeys) {
            if ([key startsWithString:@"name"]) {
                NSString *lang = nil;
                if (key.length < 5) {
                    lang = @"en";
                }
                else {
                    lang = [key substringFromIndex:5];
                }
                
                names[lang] = self.cityMetadata[key];
            }
        }
        
        city.name = [names copy];
        city.version = self.cityMetadata[@"ver"];
        city.path = self.cityMetadata[@"path"];
        
        city.metaDictionary = self.cityMetadata;
    }
    
    return city;
}

- (NSArray *)parseFileAtURL:(NSURL *)csvURL
{
    NTYCSVTable *table = [[NTYCSVTable alloc] initWithContentsOfURL:csvURL columnSeparator:@";"];
    
    return [table rows];
}

@end
