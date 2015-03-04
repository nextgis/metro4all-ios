//
//  MFAStationMapViewModel.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class MFAStation;

@interface MFAStationMapViewModel : NSObject

@property (nonatomic, readonly) NSString *stationName;
@property (nonatomic, readonly) CLLocationCoordinate2D stationPos;

@property (nonatomic, strong, readonly) NSArray *portals;

- (instancetype)initWithStation:(MFAStation *)station;

@end
