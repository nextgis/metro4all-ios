//
//  MFAStationsListViewModel.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MFACity;

@interface MFAStationsListViewModel : NSObject

- (instancetype)initWithCity:(MFACity *)city;

@property (nonatomic, strong, readonly) NSArray *stations;
@property (nonatomic, strong, readonly) NSArray *lines;
@property (nonatomic, readonly) NSString *cityName;

@end
