//
//  MFASelectCityViewModel.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "NSDictionary+CityMeta.h"

@class MFACity;

@interface MFASelectCityViewModel : NSObject

@property (nonatomic, strong, readonly) MFACityMeta *selectedCityMeta;
@property (nonatomic, strong, readonly) MFACity *selectedCity;
@property (nonatomic, readonly) BOOL hasData;

@property (nonatomic, strong) RACCommand *loadMetaFromServerCommand;

- (void)changeCity:(MFACity *)city;
- (void)deleteCityAtIndex:(NSUInteger)index;
- (void)downloadCity:(MFACityMeta *)meta completion:(void (^)())completionBlock;
- (void)downloadCityAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)())completionBlock;

#pragma mark - Table View

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;
- (NSDictionary *)viewModelForRow:(NSUInteger)row inSection:(NSUInteger)section;
- (NSString *)titleForHeaderInSection:(NSUInteger)section;

@end
