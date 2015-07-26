//
//  MFACityManager.h
//  metro4all-ios
//
//  Created by marvin on 26.07.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MFACityManager : NSObject

+ (instancetype)sharedManager;
+ (void)setSharedManager:(id)manager;

@property (nonatomic, readonly) NSArray *downloadedCities;
@property (nonatomic, readonly) NSArray *availbleCities;

- (instancetype)initWithDataURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

- (void)updateMetaWithSuccess:(void (^)(NSArray *meta))successBlock error:(void (^)(NSError *error))errorBlock;
- (void)downloadCityWithIdentifier:(NSString *)identifier unzipToPath:(NSString *)path
                          progress:(void (^)(float progress))progressBlock
                           success:(void (^)())successBlock
                             error:(void (^)(NSError *error))errorBlock;
@end
