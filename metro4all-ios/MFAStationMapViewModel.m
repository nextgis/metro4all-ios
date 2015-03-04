//
//  MFAStationMapViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFAStationMapViewModel.h"
#import "MFAStation.h"

@interface MFAStationMapViewModel ()

@property (nonatomic, strong) MFAStation *station;

@end

@implementation MFAStationMapViewModel

- (instancetype)initWithStation:(MFAStation *)station
{
    self = [super init];
    if (self) {
        self.station = station;
    }
    
    return self;
}

- (NSString *)stationName
{
    return self.station.name;
}

- (CLLocationCoordinate2D)stationPos
{
    return CLLocationCoordinate2DMake(self.station.latValue, self.station.lonValue);
}

@end
