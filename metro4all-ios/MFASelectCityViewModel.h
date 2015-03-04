//
//  MFASelectCityViewModel.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MFACity;

@interface MFASelectCityViewModel : NSObject

@property (nonatomic, strong, readonly) NSDictionary *selectedCityMeta;
@property (nonatomic, strong, readonly) NSArray *cities;
@property (nonatomic, strong, readonly) MFACity *selectedCity;

- (void)loadCitiesWithCompletion:(void(^)(void))completionBlock;
- (void)processCityMeta:(NSDictionary *)selectedCity withCompletion:(void (^)(void))completionBlock error:(void (^)(NSError *))errorBlock;

@end
