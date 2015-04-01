//
//  MFAPortalAnnotation.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 27.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MFAPortalAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSNumber *portalNumber;
@property (nonatomic, copy) NSString *stationName;

/// YES if portal belongs to station in the same interchange node,
/// but not the station itself
@property (nonatomic, assign) BOOL nodePortal;

@end
