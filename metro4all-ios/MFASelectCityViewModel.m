//
//  MFASelectCityViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <SSZipArchive/SSZipArchive.h>

#import "MFASelectCityViewModel.h"
#import "MFACityDataParser.h"

@interface MFASelectCityViewModel () <NSURLSessionDownloadDelegate, SSZipArchiveDelegate, MFACityDataParserDelegate>

@property (nonatomic, strong) MFACityDataParser *parser;
@property (nonatomic, strong) void (^completionBlock)(void);
@property (nonatomic, strong) void (^errorBlock)(NSError *);

@property (nonatomic, strong, readwrite) NSArray *cities;
@property (nonatomic, strong, readwrite) MFACity *selectedCity;
@property (nonatomic, strong, readwrite) NSDictionary *selectedCityMeta;

@property (nonatomic, strong) MFACityArchiveService *archiveService;

@end

@implementation MFASelectCityViewModel
@synthesize loadMetaFromServerCommand = _loadMetaFromServerCommand;

- (instancetype)initWithCityArchiveService:(MFACityArchiveService *)archiveService
{
    self = [super init];
    if (self) {
        self.archiveService = archiveService;
    }
    
    return self;
}

- (RACCommand *)loadMetaFromServerCommand
{
    if (!_loadMetaFromServerCommand) {
        _loadMetaFromServerCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            RACSignal *loadMetaSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler mainThreadScheduler]
                                                                       block:^(id<RACSubscriber> subscriber) {
                [self loadCitiesWithCompletion:^{
                    if (self.cities.count == 0) {
                        [subscriber sendError:[NSError errorWithDomain:@"org.metro4all.metro4all-ios"
                                                                  code:1
                                                              userInfo:@{ NSLocalizedDescriptionKey : @"Failed to get list of available cities" }]];
                    }
                    else {
                        [subscriber sendCompleted];
                    }
                }];
            }];
            
            return loadMetaSignal;
        }];
    }
    
    return _loadMetaFromServerCommand;
}

- (void)loadCitiesWithCompletion:(void (^)(void))completionBlock
{
    [self.archiveService loadCitiesWithCompletion:^(NSArray *citiesMeta) {
        self.cities = citiesMeta;
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)processCityMeta:(NSDictionary *)selectedCity withCompletion:(void (^)(void))completionBlock error:(void (^)(NSError *))errorBlock
{
    self.selectedCityMeta = selectedCity;
    
    self.completionBlock = completionBlock;
    self.errorBlock = errorBlock;
    
    // download archive with city data
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSURL *archiveURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://metro4all.org/data/v2.7/%@.zip", selectedCity[@"path"]]];
    
    [SVProgressHUD showWithStatus:@"Загружаются данные города" maskType:SVProgressHUDMaskTypeBlack];
    [[session downloadTaskWithURL:archiveURL] resume];
}

- (void)handleError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
    self.completionBlock = nil;
    
    if (!self.errorBlock) {
        return;
    }
    
    self.errorBlock(error);
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Successfully loaded zip for %@ to %@", self.selectedCityMeta[@"name"], location);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSAssert(basePath, @"Cannot get path to Documents directory");
    
    NSURL *pathURL = [NSURL fileURLWithPath:basePath];
    pathURL = [NSURL URLWithString:[NSString stringWithFormat:@"data/%@", self.selectedCityMeta[@"path"]]
                     relativeToURL:pathURL];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[[[pathURL filePathURL] absoluteURL] path]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    
    if (error) {
        NSLog(@"Failed to create directory structure: %@", error);
        
        [self handleError:[NSError errorWithDomain:@"ru.metro4all.zipArchiver"
                                              code:1
                                          userInfo:@{ NSLocalizedDescriptionKey : @"Failed to create directory structure" }]];
        return;
    }
    
//    [SVProgressHUD showWithStatus:@"Загружаются данные города" maskType:SVProgressHUDMaskTypeBlack];
    
    error = nil;
    [SSZipArchive unzipFileAtPath:[[location filePathURL] path]
                    toDestination:[[pathURL filePathURL] path]
                        overwrite:YES
                         password:nil
                            error:&error
                         delegate:self];
    
    if (error) {
        NSLog(@"Failed to open zip archive: %@", error);
        
        [self handleError:[NSError errorWithDomain:@"ru.metro4all.zipUnarchiver"
                                              code:1
                                          userInfo:@{ NSLocalizedDescriptionKey : @"Failed to open zip archive" }]];
        return;
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
//    if (totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD showProgress:(((float)totalBytesWritten) / totalBytesExpectedToWrite)
//                                 status:@"Загружаются данные города"
//                               maskType:SVProgressHUDMaskTypeBlack];
//        });
//    }
}

#pragma mark - SSZipArchive Delegate

- (void)zipArchiveProgressEvent:(NSInteger)loaded total:(NSInteger)total
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [SVProgressHUD showProgress:(((float)loaded)/total)
//                             status:@"Распаковка данных"
//                           maskType:SVProgressHUDMaskTypeBlack];
//    });
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    NSLog(@"Successfully unzipped data for %@ into %@", self.selectedCityMeta[@"name"], unzippedPath);
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [SVProgressHUD dismiss];
//    });
    
    NSManagedObjectContext *moc =
        [[UIApplication sharedApplication].delegate performSelector:@selector(managedObjectContext)];
    
    MFACityDataParser *parser =
        [[MFACityDataParser alloc] initWithCityMeta:self.selectedCityMeta
                                          pathToCSV:unzippedPath
                               managedObjectContext:moc
                                           delegate:self];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [SVProgressHUD showProgress:0.0
//                             status:@"Обработка данных"
//                           maskType:SVProgressHUDMaskTypeBlack];
//    });
    
    self.parser = parser;
    [parser start];
}

#pragma mark - MFACityDataParser Delegate

- (void)cityDataParser:(MFACityDataParser *)parser didProcessFiles:(NSUInteger)precessedFiles ofTotalFiles:(NSUInteger)totalFiles
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [SVProgressHUD showProgress:(((float)precessedFiles)/totalFiles)
//                             status:@"Обработка данных"
//                           maskType:SVProgressHUDMaskTypeBlack];
//    });
}

- (void)cityDataParserDidFail:(MFACityDataParser *)parser
{
    NSLog(@"Failed to process CSV data");
    
    [self handleError:[NSError errorWithDomain:@"ru.metro4all.csvParser"
                                          code:1
                                      userInfo:@{ NSLocalizedDescriptionKey : @"Failed to process CSV data" }]];
    
    self.parser = nil;
}

- (void)cityDataParser:(MFACityDataParser *)parser didFinishParsingCity:(MFACity *)city
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Данные загружены" maskType:SVProgressHUDMaskTypeBlack];
        
        self.selectedCity = city;
        self.parser = nil;

        [[NSUserDefaults standardUserDefaults] setObject:parser.cityMetadata forKey:@"MFA_CURRENT_CITY"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MFA_CHANGE_CITY" object:nil];

        if (self.completionBlock) {
            self.completionBlock();
            self.completionBlock = nil;
        }
    });
}

@end