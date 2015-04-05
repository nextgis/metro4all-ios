//
//  MFASelectCityViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "AppDelegate.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <SSZipArchive/SSZipArchive.h>

#import "MFASelectCityViewModel.h"
#import "MFACityDataParser.h"
#import "MFACity.h"

@interface MFASelectCityViewModel () <NSURLSessionDownloadDelegate, SSZipArchiveDelegate, MFACityDataParserDelegate>

@property (nonatomic, strong) MFACityDataParser *parser;
@property (nonatomic, strong) void (^completionBlock)(void);
@property (nonatomic, strong) void (^errorBlock)(NSError *);

/// Cities that are already downloaded on the device (MFACity *)
@property (nonatomic, strong, readwrite) NSArray *loadedCities;

/// Cities loaded from server (NSDictionary * meta)
@property (nonatomic, strong, readwrite) NSArray *cities;

@property (nonatomic, strong, readwrite) MFACity *selectedCity;
@property (nonatomic, strong, readwrite) NSDictionary *selectedCityMeta;

@property (nonatomic, strong) MFACityArchiveService *archiveService;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

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

- (NSManagedObjectContext *)managedObjectContext
{
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
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

- (NSArray *)loadedCities
{
    if (_loadedCities == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:self.managedObjectContext];

        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nameString"
                                                                       ascending:YES];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        _loadedCities = [fetchedObjects sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    }
    
    return _loadedCities;
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
    
    NSURL *unzippedPath = [self directoryForUnzippingCity:selectedCity[@"path"] metaVersion:selectedCity[@"ver"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:unzippedPath.path]) {
        // download archive with city data
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                              delegate:self
                                                         delegateQueue:[[NSOperationQueue alloc] init]];
        
        NSURL *archiveURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://metro4all.org/data/v2.7/%@.zip", selectedCity[@"path"]]];
        [[session downloadTaskWithURL:archiveURL] resume];
    }
    else {
        // don't download data again
        
        MFACityDataParser *parser =
        [[MFACityDataParser alloc] initWithCityMeta:self.selectedCityMeta
                                          pathToCSV:unzippedPath.path
                               managedObjectContext:self.managedObjectContext
                                           delegate:self];
        
        self.parser = parser;
        [parser start];
    }
}

- (void)handleError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionBlock = nil;
        
        if (self.errorBlock) {
            self.errorBlock(error);
        }
        
        self.errorBlock = nil;
    });
}

#pragma mark - NSURLSession Delegate

- (NSURL *)directoryForUnzippingCity:(NSString *)cityIdentifier metaVersion:(NSNumber *)version
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSAssert(basePath, @"Cannot get path to Documents directory");
    
    NSURL *pathURL = [NSURL fileURLWithPath:basePath];
    pathURL = [NSURL URLWithString:[NSString stringWithFormat:@"data/%@_%@", cityIdentifier, version]
                     relativeToURL:pathURL];
    
    return pathURL;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Successfully loaded zip for %@ to %@", self.selectedCityMeta[@"name"], location);
    
    NSURL *pathURL = [self directoryForUnzippingCity:self.selectedCityMeta[@"path"] metaVersion:self.selectedCityMeta[@"ver"]];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[[[pathURL filePathURL] absoluteURL] path]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    
    if (error) {
        NSLog(@"Failed to create directory structure: %@", error);
        
        [self handleError:[NSError errorWithDomain:@"ru.metro4all.zipUnarchiver"
                                              code:1
                                          userInfo:@{ NSLocalizedDescriptionKey : @"Failed to create directory structure" }]];
        return;
    }
    
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
                                              code:2
                                          userInfo:@{ NSLocalizedDescriptionKey : @"Failed to open zip archive" }]];
        return;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"Failed to load zip archive: %@", error);
        
        [self handleError:[NSError errorWithDomain:@"ru.metro4all.zipUnarchiver"
                                              code:3
                                          userInfo:@{ NSLocalizedDescriptionKey : @"Failed load zip archive" }]];
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
        self.selectedCity = city;
        self.parser = nil;

        [self changeCity:city];

        if (self.completionBlock) {
            self.completionBlock();
            self.completionBlock = nil;
        }
    });
}

- (void)changeCity:(MFACity *)city
{
    [[NSUserDefaults standardUserDefaults] setObject:city.metaDictionary forKey:@"MFA_CURRENT_CITY"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFA_CHANGE_CITY" object:nil];
}

#pragma mark - Table View

- (NSUInteger)numberOfSections
{
    if (self.loadedCities.count > 0) {
        return 2;
    }
    
    return 1;
}

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section
{
    if (section == 1 || self.numberOfSections == 1) {
        return self.cities.count;
    }
    else {
        return self.loadedCities.count;
    }
}

- (NSDictionary *)viewModelForRow:(NSUInteger)row inSection:(NSUInteger)section
{
    if (section == 1 || self.numberOfSections == 1) {
        return self.cities[row];
    }
    else {
        return [self.loadedCities[row] metaDictionary];
    }
}

- (NSString *)titleForHeaderInSection:(NSUInteger)section
{
    if (section == 1) {
        return @"Доступные";
    }
    else if (self.numberOfSections == 1) {
        return nil;
    }
    else {
        return @"На устройстве";
    }
}

@end