//
//  MFASelectCityViewModel.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFASelectCityViewModel : NSObject

@property (nonatomic, strong, readwrite) NSDictionary *selectedCity;
@property (nonatomic, strong, readonly) NSArray *cities;

- (void)loadCitiesWithCompletion:(void(^)(void))completionBlock;

@end
