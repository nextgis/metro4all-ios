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

@end
