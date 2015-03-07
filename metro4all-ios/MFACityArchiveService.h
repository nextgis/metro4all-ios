//
//  MFACityArchiveService.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 07.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFACityArchiveService : NSObject

@property (nonatomic, copy) NSString *url;

- (instancetype)initWithUrl:(NSString *)url;

- (void)loadCitiesWithCompletion:(void (^)(NSArray *citiesMeta))completionBlock;

@end
