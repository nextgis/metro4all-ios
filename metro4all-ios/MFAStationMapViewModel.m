
//
//  MFAStationMapViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "AppDelegate.h"

#import "MFAStationMapViewModel.h"
#import "MFAPortalAnnotation.h"

#import "MFAStation.h"
#import "MFACity.h"
#import "MFAPortal.h"
#import "MFANode.h"

@interface MFAStationMapViewModel ()

@property (nonatomic, strong) MFAStation *station;

@property (nonatomic, readwrite) CLLocationCoordinate2D stationPos;
@property (nonatomic, strong, readwrite) NSArray *pins;

@end

@implementation MFAStationMapViewModel

@synthesize stationSchemeImage = _stationSchemeImage;
@synthesize stationSchemeOverlayImage = _stationSchemeOverlayImage;

- (instancetype)initWithStation:(MFAStation *)station
{
    self = [super init];
    if (self) {
        self.station = station;
        self.stationPos = CLLocationCoordinate2DMake(self.station.latValue,
                                                     self.station.lonValue);
        
        self.showsMap = YES;
        self.showsObstacles = NO;
        
        NSSet *nodePortals = [self.station.node.stations valueForKeyPath:@"@distinctUnionOfSets.portals"];
        NSMutableDictionary *portalsCache = [NSMutableDictionary new];
        
        for (MFAPortal *portal in nodePortals) {
            if (portalsCache[portal.portalNumber]) {
                continue;
            }

            MFAPortalAnnotation *annotation = [[MFAPortalAnnotation alloc] init];
            
            annotation.coordinate = CLLocationCoordinate2DMake(portal.lat.doubleValue,
                                                               portal.lon.doubleValue);
            
            annotation.title = [NSString stringWithFormat:@"Выход #%@", [portal.portalNumber stringValue]];
            
            NSUInteger count = [[self.station.portals objectsPassingTest:^BOOL(id obj, BOOL *stop) {
                return [[obj portalNumber] isEqualToNumber:portal.portalNumber];
            }] count];
            
            if (count == 0) {
                annotation.nodePortal = YES;
            }
            
            annotation.subtitle = portal.nameString;
            annotation.portalNumber = portal.portalNumber;
            
            portalsCache[portal.portalNumber] = annotation;
        }
        
        self.pins = [portalsCache allValues];
    }
    
    return self;
}

- (NSString *)stationName
{
    return self.station.nameString;
}

- (UIImage *)stationSchemeImage
{
    if (!_stationSchemeImage) {
        MFACity *city = self.station.city;
        
        NSURL *dataURL = [city.dataDirectory.absoluteURL copy];
        NSURL *schemeURL = [NSURL URLWithString:[NSString stringWithFormat:@"schemes/%ld.png", (long)self.station.node.nodeId.integerValue]
                                                             relativeToURL:dataURL];
        NSString *schemeFilePath = [schemeURL path];
        
        _stationSchemeImage = [UIImage imageWithContentsOfFile:schemeFilePath];
    }
    
    return _stationSchemeImage;
}

- (UIImage *)stationSchemeOverlayImage
{
    if (!_stationSchemeOverlayImage) {
        MFACity *city = self.station.city;
        
        NSURL *dataURL = [city.dataDirectory.absoluteURL copy];
        NSURL *schemeURL = [NSURL URLWithString:[NSString stringWithFormat:@"schemes/numbers/%ld.png", (long)self.station.node.nodeId.integerValue]
                                  relativeToURL:dataURL];
        NSString *schemeFilePath = [schemeURL path];

        _stationSchemeOverlayImage = [UIImage imageWithContentsOfFile:schemeFilePath];
    }
    
    return _stationSchemeOverlayImage;
}

@end
