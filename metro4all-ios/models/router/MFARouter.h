//
//  MFARouter.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 15/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFAStation.h"
#import "NSDictionary+CityMeta.h"

@interface MFARouter : NSObject

- (instancetype)initWithStations:(NSArray *)stations edges:(NSArray *)edges;
- (NSArray *)routeFromStation:(NSNumber *)stationIdFrom toStation:(NSNumber *)stationIdTo;

@end
