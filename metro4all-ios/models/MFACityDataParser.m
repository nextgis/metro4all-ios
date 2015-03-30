//
//  MFACityDataParser.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 03.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NTYCSVTable/NTYCSVTable.h>

#import "NSString+Utils.h"

#import "MFACity.h"
#import "MFALine.h"
#import "MFAStation.h"
#import "MFAPortal.h"

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
    MFACity *city = [self configureCity];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.csvPath error:nil];
    const NSUInteger totalFiles = files.count;
    NSUInteger processedFiles = 0;
    
    NSMutableDictionary *linesCache = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *stationsCache = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *portalsCache = [[NSMutableDictionary alloc] init];
    
    files = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject startsWithString:@"lines"] ||
            [evaluatedObject startsWithString:@"portals"] ||
            [evaluatedObject startsWithString:@"stations"]) {
            
            return YES;
        }
        
        return NO;
    }]];
    
    files = [files sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        NSNumber *rep1 = nil, *rep2 = nil;
        if ([obj1 startsWithString:@"lines"]) {
            rep1 = @0;
        }
        else if ([obj1 startsWithString:@"stations"]) {
            rep1 = @1;
        }
        else {
            rep1 = @2;
        }
        
        if ([obj2 startsWithString:@"lines"]) {
            rep2 = @0;
        }
        else if ([obj2 startsWithString:@"stations"]) {
            rep2 = @1;
        }
        else {
            rep2 = @2;
        }
        
        return [rep1 compare:rep2];
    }];
    
    for (NSString *filePath in files) {
        if ([filePath startsWithString:@"lines"]) {
            [self parseLinesFromFile:filePath
                          linesCache:linesCache];
        }
        else if ([filePath startsWithString:@"stations"]) {
            [self parseStationsFromFile:filePath
                             linesCache:linesCache
                          stationsCache:stationsCache];
        }
        else if ([filePath startsWithString:@"portals"]) {
            [self parsePortalsFromFile:filePath
                         stationsCache:stationsCache
                          portalsCache:portalsCache];
        }
        
        if ([self.delegate respondsToSelector:@selector(cityDataParser:didProcessFiles:ofTotalFiles:)]) {
            [self.delegate cityDataParser:self didProcessFiles:++processedFiles ofTotalFiles:totalFiles];
        }
    }
    
    for (id key in linesCache) {
        [linesCache[key] setCity:city];
    }
    
    for (id key in stationsCache) {
        [stationsCache[key] setCity:city];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        
    });
    
    [self.delegate cityDataParser:self didFinishParsingCity:city];
}

- (void)parseLinesFromFile:(NSString *)filePath linesCache:(NSMutableDictionary *)linesCache
{
    NSArray *parsedLines = [self parseFileAtURL:[NSURL URLWithString:filePath
                                                       relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    
    NSString *lang = [filePath substringWithRange:NSMakeRange(6, 2)];
    
    for (NSDictionary *lineProperties in parsedLines) {
        NSNumber *lineId = lineProperties[@"id_line"];
        
        if (linesCache[lineId] == nil) {
            MFALine *line = [MFALine insertInManagedObjectContext:self.managedObjectContext];
        
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
{
    NSArray *parsedStations = [self parseFileAtURL:[NSURL URLWithString:filePath
                                                          relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    
    NSString *lang = [filePath substringWithRange:NSMakeRange(9, 2)];
    
    for (NSDictionary *stationProperties in parsedStations) {
        NSNumber *stationId = stationProperties[@"id_station"];
        
        if (stationsCache[stationId] == nil) {
            MFAStation *station = [MFAStation insertInManagedObjectContext:self.managedObjectContext];
            
            station.nodeId = stationProperties[@"id_node"];
            station.stationId = stationId;
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
{
    NSArray *parsedPortals = [self parseFileAtURL:[NSURL URLWithString:filePath
                                                         relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    
    NSString *lang = [filePath substringWithRange:NSMakeRange(8, 2)];
    
    for (NSDictionary *portalProperties in parsedPortals) {
        NSNumber *portalId = portalProperties[@"id_entrance"];
        
        if (portalsCache[portalId] == nil) {
            MFAPortal *portal = [MFAPortal insertInManagedObjectContext:self.managedObjectContext];
        
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

- (MFACity *)configureCity
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"path == %@", self.cityMetadata[@"path"]];
    [fetchRequest setPredicate:predicate];
    
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                       error:&error];
    MFACity *city = [fetchedObjects firstObject];
    if (city) {
        // updating info about city
        NSLog(@"Found stored city: %@, version: %@", self.cityMetadata[@"name"],
              self.cityMetadata[@"ver"]);
        
        // Delete the old city object.
        // It will cascade to all info related to this city: stations, lines, portals, etc.
        [self.managedObjectContext deleteObject:city];
    }
    
    // create new city
    city = [MFACity insertInManagedObjectContext:self.managedObjectContext];
    
    // extract names in different languages into Dictionary
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
    
    return city;
}

- (NSArray *)parseFileAtURL:(NSURL *)csvURL
{
    NTYCSVTable *table = [[NTYCSVTable alloc] initWithContentsOfURL:csvURL columnSeparator:@";"];
    
    return [table rows];
}

@end
