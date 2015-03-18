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

@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, strong, readonly) NSArray *searchResults;

@property (nonatomic, strong, readonly) NSArray *allStations;

@property (nonatomic, readonly) NSString *screenTitle;

@end
