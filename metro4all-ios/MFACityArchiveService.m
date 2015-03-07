//
//  MFACityArchiveService.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 07.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "MFACityArchiveService.h"

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
    
    AFJSONRequestOperation *jsonRequest =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                        success:^(NSURLRequest *req, NSHTTPURLResponse *res, id JSON) {
                                                            NSLog(@"Successfully loaded meta.json");
                                                            
                                                            if (completionBlock) {
                                                                completionBlock(JSON[@"packages"]);
                                                            }
                                                        }
         
                                                        failure:^(NSURLRequest *req, NSHTTPURLResponse *res, NSError *err, id JSON) {
                                                            NSLog(@"Failed to get meta.json: %@", err);
                                                            
                                                            if (completionBlock) {
                                                                completionBlock(nil);
                                                            }
                                                        }];
    
    [client enqueueHTTPRequestOperation:jsonRequest];
}

@end
