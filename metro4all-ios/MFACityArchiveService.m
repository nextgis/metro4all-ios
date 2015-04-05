//
//  MFACityArchiveService.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 07.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "MFACityArchiveService.h"

NSString * getLocalizedName(NSDictionary *cityMeta)
{
    NSString *name = nil;
    for (NSString *lang in [NSLocale preferredLanguages]) {
        name = cityMeta[[@"name_" stringByAppendingString:lang]];
        
        if (name != nil) {
            return name;
        }
    }
    
    return cityMeta[@"name"]; // default to english
}

@implementation MFACityArchiveService

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    
    return self;
}

- (void)loadCitiesWithCompletion:(void (^)(NSArray *citiesMeta))completionBlock;
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:@"http://metro4all.org"]];
    
    NSURL *metaURL = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:metaURL];

    id successBlock = ^(NSURLRequest *req, NSHTTPURLResponse *res, id JSON) {
        NSLog(@"Successfully loaded meta.json");
        
        NSArray *sorted = [JSON[@"packages"] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *city1, NSDictionary *city2) {
            return [getLocalizedName(city1) compare:getLocalizedName(city2)];
        }];
        
        if (completionBlock) {
            completionBlock(sorted);
        }
    };
    
    AFJSONRequestOperation *jsonRequest =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                        success:successBlock
                                                        failure:^(NSURLRequest *req, NSHTTPURLResponse *res, NSError *err, id JSON) {
                                                            NSLog(@"Failed to get meta.json: %@", err);
                                                            
                                                            if (completionBlock) {
                                                                completionBlock(nil);
                                                            }
                                                        }];
    
    [client enqueueHTTPRequestOperation:jsonRequest];
}

@end
