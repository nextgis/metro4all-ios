//
//  MFACityDataParser.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 03.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NTYCSVTable/NTYCSVTable.h>

#import "MFACity.h"
#import "MFALine.h"
#import "MFAStation.h"
#import "MFAPortal.h"

#import "MFACityDataParser.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                                 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                                  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];


@interface MFACityDataParser ()

@property (nonatomic, copy) NSDictionary *cityMetadata;
@property (nonatomic, copy) NSString *csvPath;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

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

- (void)start
{
    const NSUInteger totalFiles = 3;
    
    MFACity *city = [self configureCity];
    
    NSArray *parsedLines = [self parseFileAtURL:[NSURL URLWithString:@"lines_ru.csv"
                                                       relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    NSMutableDictionary *linesCache = [[NSMutableDictionary alloc] initWithCapacity:parsedLines.count];
    
    
    for (NSDictionary *lineProperties in parsedLines) {
        MFALine *line = [MFALine insertInManagedObjectContext:self.managedObjectContext];
        
        line.lineId = lineProperties[@"id_line"];
        line.name = lineProperties[@"name"];
        
        NSScanner *colorScanner = [[NSScanner alloc] initWithString:lineProperties[@"color"]];
        colorScanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"#"];
        
        unsigned int intColor = 0;
        [colorScanner scanHexInt:&intColor];
        
        line.color = UIColorFromRGB(intColor)
        
        line.city = city;
        
        linesCache[line.lineId] = line;
    }
    
    if ([self.delegate respondsToSelector:@selector(cityDataParser:didProcessFiles:ofTotalFiles:)]) {
        [self.delegate cityDataParser:self didProcessFiles:1 ofTotalFiles:totalFiles];
    }
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSArray *parsedStations = [self parseFileAtURL:[NSURL URLWithString:@"stations_ru.csv"
                                                          relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    NSMutableDictionary *stationsCache = [[NSMutableDictionary alloc] initWithCapacity:parsedStations.count];
 
    for (NSDictionary *stationProperties in parsedStations) {
        MFAStation *station = [MFAStation insertInManagedObjectContext:self.managedObjectContext];
        
        station.stationId = stationProperties[@"id_station"];
        station.lineId = stationProperties[@"id_line"];
        station.name = stationProperties[@"name"];
        station.lat = stationProperties[@"lat"];
        station.lon = stationProperties[@"lon"];
        
        station.line = linesCache[station.lineId];
        station.city = city;
        
        stationsCache[station.stationId] = station;
    }

    if ([self.delegate respondsToSelector:@selector(cityDataParser:didProcessFiles:ofTotalFiles:)]) {
        [self.delegate cityDataParser:self didProcessFiles:2 ofTotalFiles:totalFiles];
    }

    NSArray *parsedPortals = [self parseFileAtURL:[NSURL URLWithString:@"portals_ru.csv"
                                          relativeToURL:[NSURL fileURLWithPath:self.csvPath]]];
    
    for (NSDictionary *portalProperties in parsedPortals) {
        MFAPortal *portal = [MFAPortal insertInManagedObjectContext:self.managedObjectContext];
        
        portal.potralId = portalProperties[@"id_entrance"];
        portal.portalNumber = portalProperties[@"meetcode"];
        portal.name = portalProperties[@"name"];
        portal.stationId = portalProperties[@"id_station"];
        //    self.directionValue =
        portal.lat = portalProperties[@"lat"];
        portal.lon = portalProperties[@"lon"];
        
        portal.station = stationsCache[portal.stationId];
    }
    
    if ([self.delegate respondsToSelector:@selector(cityDataParser:didProcessFiles:ofTotalFiles:)]) {
        [self.delegate cityDataParser:self didProcessFiles:3 ofTotalFiles:totalFiles];
    }

    [self.managedObjectContext save:nil];
    
    [self.delegate cityDataParser:self didFinishParsingCity:city];
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
    city.name = self.cityMetadata[@"name_ru"];
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
