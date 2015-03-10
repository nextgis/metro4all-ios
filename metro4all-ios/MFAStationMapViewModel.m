//
//  MFAStationMapViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "AppDelegate.h"

#import "MFAStationMapViewModel.h"
#import "MFAStation.h"
#import "MFACity.h"
#import "MFAPortal.h"

@interface MFAStationMapViewModel ()

@property (nonatomic, strong) MFAStation *station;

@property (nonatomic, readwrite) CLLocationCoordinate2D stationPos;
@property (nonatomic, strong, readwrite) NSArray *pins;

@end

@implementation MFAStationMapViewModel

@synthesize stationSchemeImage = _stationSchemeImage;

- (instancetype)initWithStation:(MFAStation *)station
{
    self = [super init];
    if (self) {
        self.station = station;
        self.stationPos = CLLocationCoordinate2DMake(self.station.latValue,
                                                     self.station.lonValue);
        
        self.showsMap = YES;
        self.showsPortals = NO;
        self.showsObstacles = NO;
    }
    
    return self;
}

- (NSString *)stationName
{
    return self.station.name;
}

- (UIImage *)stationSchemeImage
{
    if (!_stationSchemeImage) {
        MFACity *city = self.station.city;
        
        NSString *imageFile = [NSString stringWithFormat:@"data/%@/schemes/%ld", city.path, (long)self.station.nodeId.integerValue];
        
        NSURL *documentsDirURL = [((AppDelegate *)[UIApplication sharedApplication].delegate) applicationDocumentsDirectory];
        
        NSURL *schemeImageURL = [NSURL URLWithString:imageFile
                                       relativeToURL:documentsDirURL];
        
        NSString *schemeFilePath = [schemeImageURL path];
        
        _stationSchemeImage = [UIImage imageWithContentsOfFile:schemeFilePath];
    }
    
    return _stationSchemeImage;
}

- (void)setShowsPortals:(BOOL)showsPortals
{
    _showsPortals = showsPortals;
    
    NSMutableArray *pins = [NSMutableArray new];
    
    if (showsPortals) {
        for (MFAPortal *portal in self.station.portals) {
            [pins addObject:@{ @"name" : portal.name,
                              @"lat" : portal.lat,
                              @"lon" : portal.lon }];
        }
    }
    
    [pins addObject:@{ @"name" : self.station.name,
                       @"lat" : self.station.lat,
                       @"lon" : self.station.lon }];
    
    self.pins = pins;
}

@end
