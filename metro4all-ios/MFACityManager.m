//
//  MFACityManager.m
//  metro4all-ios
//
//  Created by marvin on 26.07.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <SSZipArchive/SSZipArchive.h>
#import <MagicalRecord/MagicalRecord.h>

#import "MFACityManager.h"
#import "NSDictionary+CityMeta.h"
#import "MFACity.h"

static MFACityManager *sharedManager = nil;

@interface MFACityManager ()

@property (nonatomic, strong) NSURL *dataURL;
@property (nonatomic, strong) NSDictionary *meta;

@property (nonatomic, readwrite, strong) NSArray *availableCities;

@end

@implementation MFACityManager

+ (instancetype)sharedManager
{
    return sharedManager;
}

+ (void)setSharedManager:(id)manager
{
    sharedManager = manager;
}

- (instancetype)initWithDataURL:(NSURL * __nonnull)url
{
    self = [super init];
    if (self) {
        self.dataURL = url;
    }
    
    return self;
}

- (void)updateMetaWithSuccess:(void (^)(NSArray *meta))successBlock error:(void (^)(NSError *error))errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURL *metaURL = [NSURL URLWithString:@"meta.json" relativeToURL:self.dataURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:metaURL];
    
    AFHTTPRequestOperation *op = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully loaded meta.json");
        
        // save json for future use
        NSURL *metaJsonFileURL = [MFACityMeta metaJsonFileURL];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        [jsonData writeToURL:metaJsonFileURL options:0 error:nil];
        
        NSMutableArray *sorted = [[responseObject[@"packages"] sortedArrayUsingComparator:^NSComparisonResult(MFACityMeta *city1, MFACityMeta *city2) {
            return [city1.localizedName compare:city2.localizedName];
        }] mutableCopy];

        NSMutableArray *citiesToUpdate = [NSMutableArray new];
        
        for (NSUInteger i = 0; i < sorted.count; i++) {
            MFACityMeta *meta = sorted[i];
            MFACity *city = [MFACity cityWithIdentifier:meta[@"path"]];

            if (city) {
                [sorted removeObjectAtIndex:i];
                
                NSMutableDictionary *mutableMeta = [meta mutableCopy];
                if (city.version.unsignedIntegerValue < [meta[@"ver"] unsignedIntegerValue]) {
                    mutableMeta[@"updateAvailable"] = @YES;
                    [citiesToUpdate addObject:meta.localizedName];
                }
                else {
                    mutableMeta[@"updateAvailable"] = @NO;
                }
                
                city.updatedMeta = mutableMeta;
            }
        }
        
        self.availableCities = [sorted copy];

        if (successBlock) {
            successBlock(sorted);
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MFA_UPDATES_AVAILABLE" object:nil userInfo:@{ @"cities" : citiesToUpdate }];
        }
    }
                                                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                      NSLog(@"Failed to get meta.json: %@", error);
                                                                      
                                                                      if (errorBlock) {
                                                                          errorBlock(error);
                                                                      }
                                                                  }];
    
    [op start];
}

- (void)downloadCityWithIdentifier:(NSString *)identifier unzipToPath:(NSString *)path
                          progress:(void (^)(float progress))progressBlock
                           success:(void (^)())successBlock
                             error:(void (^)(NSError *error))errorBlock
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        // download archive with city data
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *filename = [NSString stringWithFormat:@"%@.zip", identifier];
        NSString *zipPath = [[MFACityMeta dataDirectoryPath] stringByAppendingPathComponent:filename];
        NSURL *archiveURL = [NSURL URLWithString:filename relativeToURL:self.dataURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:archiveURL];
        
        AFHTTPRequestOperation *op = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Succesfully downloaded %@", zipPath);
            
            NSError *error = nil;
            BOOL unzippedSuccessfully = [SSZipArchive unzipFileAtPath:zipPath
                                                        toDestination:path
                                                            overwrite:NO
                                                             password:nil
                                                                error:&error];
            
            if (!unzippedSuccessfully) {
                if (errorBlock) {
                    errorBlock(error);
                }
                
                return;
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
            
            NSMutableArray *mAvailableCities = [self.availableCities mutableCopy];
            [self.availableCities enumerateObjectsUsingBlock:^(MFACityMeta *meta, NSUInteger idx, BOOL *stop) {
                if ([meta[@"path"] isEqualToString:identifier]) {
                    [mAvailableCities removeObject:meta];
                }
            }];
            self.availableCities = [mAvailableCities copy];
            
            if (successBlock) {
                successBlock();
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to download %@", zipPath);
            
            if (errorBlock) {
                errorBlock(error);
            }
        }];
        
        op.outputStream = [NSOutputStream outputStreamToFileAtPath:zipPath append:NO];
        
        [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            NSLog(@"Downloading %@, %lld of %lld bytes", filename, totalBytesRead, totalBytesExpectedToRead);
            
            if (progressBlock) {
                progressBlock((float)totalBytesRead/totalBytesExpectedToRead);
            };
        }];
        
        [op start];
    }
    else {
        if (successBlock) {
            successBlock();
        }
    }
}

- (void)deleteCity:(MFACity *)city
{
    NSError *error = nil;
    NSURL *cityFilesURL = [((MFACityMeta *)city.metaDictionary) filesDirectory];
    [[NSFileManager defaultManager] removeItemAtPath:cityFilesURL.path error:&error];
    
    NSManagedObjectContext *moc = city.managedObjectContext;
    
    if (!error) {
        [moc deleteObject:city];
        [moc MR_saveToPersistentStoreWithCompletion:nil];
    }
}

- (NSArray *)downloadedCities
{
    return [MFACity MR_findAll];
}

@end
