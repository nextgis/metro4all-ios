//
//  NSDictionary+CityMeta.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 13.04.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary MFACityMeta;

@interface NSDictionary (CityMeta)

- (NSString *)localizedName;
- (NSURL *)filesDirectory;

+ (NSURL *)metaJsonFileURL;

@end
