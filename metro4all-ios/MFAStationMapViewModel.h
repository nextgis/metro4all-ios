//
//  MFAStationMapViewModel.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class MFAStation;

@interface MFAStationMapViewModel : NSObject

@property (nonatomic, readonly) NSString *stationName;
@property (nonatomic, readonly) CLLocationCoordinate2D stationPos;

@property (nonatomic, strong, readonly) NSArray *portals;
@property (nonatomic, strong, readonly) UIImage *stationSchemeImage;
@property (nonatomic, strong, readonly) UIImage *stationSchemeOverlayImage;

@property (nonatomic) BOOL showsMap;
@property (nonatomic) BOOL showsPortals;
@property (nonatomic) BOOL showsObstacles;

- (instancetype)initWithStation:(MFAStation *)station;

@property (nonatomic, strong, readonly) NSArray *pins;

@end
