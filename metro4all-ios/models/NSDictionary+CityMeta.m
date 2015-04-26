//
//  NSDictionary+CityMeta.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 13.04.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "NSDictionary+CityMeta.h"

@implementation NSDictionary (CityMeta)

- (NSString *)localizedName
{
    NSString *name = nil;
    for (NSString *lang in [NSLocale preferredLanguages]) {
        name = self[[@"name_" stringByAppendingString:lang]];
        
        if (name != nil) {
            return name;
        }
    }
    
    return self[@"name"]; // default to english
}

- (NSURL *)filesDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSAssert(basePath, @"Cannot get path to Documents directory");
    
    NSURL *pathURL = [NSURL fileURLWithPath:basePath];
    pathURL = [NSURL URLWithString:[NSString stringWithFormat:@"data/%@_%@", self[@"path"], self[@"ver"]]
                     relativeToURL:pathURL];
    
    return pathURL;
}

+ (NSURL *)metaJsonFileURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSAssert(basePath, @"Cannot get path to Documents directory");
    
    NSURL *pathURL = [[NSURL fileURLWithPath:basePath] URLByAppendingPathComponent:@"data/meta.json"];
    
    return pathURL;
}

@end
