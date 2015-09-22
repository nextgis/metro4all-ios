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
        name = self[[@"name_" stringByAppendingString:[lang substringToIndex:2]]];
        
        if (name != nil) {
            return name;
        }
    }
    
    return self[@"name"]; // default to english
}

- (NSURL *)filesDirectory
{
    NSURL *pathURL = [NSURL fileURLWithPath:[MFACityMeta dataDirectoryPath]];
    pathURL = [pathURL URLByAppendingPathComponent:[NSString stringWithFormat:@"data/%@_%@", self[@"path"], self[@"ver"]]];
    
    return pathURL;
}

+ (NSURL *)metaJsonFileURL
{
    NSURL *pathURL = [NSURL fileURLWithPath:[MFACityMeta dataDirectoryPath]];
    pathURL = [pathURL URLByAppendingPathComponent:@"data/meta.json"];
    
    return pathURL;
}

+ (NSString *)dataDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    return basePath;
}

@end
