//
//  MFACityArchiveService.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 07.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface MFACityArchiveService : NSObject

- (instancetype)initWithBaseURL:(NSURL *)baseUrl;

- (void)loadCitiesWithCompletion:(void (^)(NSArray *citiesMeta))completionBlock;
- (RACSignal *)getCityFilesForMetadata:(NSDictionary *)cityMeta completion:(void (^)(NSString *path, NSError *error))completion;

@end
