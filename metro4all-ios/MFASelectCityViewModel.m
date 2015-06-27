//
//  MFASelectCityViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "AppDelegate.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SSZipArchive/SSZipArchive.h>

#import "MFASelectCityViewModel.h"
#import "MFACityDataParser.h"
#import "MFACity.h"
#import "NSDictionary+CityMeta.h"

@interface MFASelectCityViewModel () <MFACityDataParserDelegate>

@property (nonatomic, strong) MFACityDataParser *parser;
@property (nonatomic, strong) void (^completionBlock)(void);
@property (nonatomic, strong) void (^errorBlock)(NSError *);

/// Cities that are already downloaded on the device (MFACity *)
@property (nonatomic, strong, readwrite) NSArray *loadedCities;

/// Cities loaded from server (NSDictionary * meta)
@property (nonatomic, strong, readwrite) NSArray *cities;

@property (nonatomic, strong, readwrite) MFACity *selectedCity;

@property (nonatomic, strong) MFACityArchiveService *archiveService;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) RACSignal *downloadProgress;

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
                [self.archiveService loadCitiesWithCompletion:^(NSArray *citiesMeta) {
                    
                    self.cities = [self checkForUpdates:citiesMeta];
                    
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

- (NSArray *)checkForUpdates:(NSArray *)citiesMeta
{
    NSMutableArray *mCitiesMeta = [[NSMutableArray alloc] initWithCapacity:citiesMeta.count];
    
    for (MFACityMeta *meta in citiesMeta) {
        MFACity *city = [MFACity cityWithIdentifier:meta[@"path"]];
        if (city == nil) {
            // add only cities that are not loaded on the device
            [mCitiesMeta addObject:meta];
            continue;
        }
        
        NSMutableDictionary *updatedMeta = [meta mutableCopy];
        if ([meta[@"ver"] integerValue] > city.versionValue) {
            updatedMeta[@"hasUpdate"] = @YES;
        }
        else {
            updatedMeta[@"hasUpdate"] = @NO;
        }
        
        updatedMeta[@"archiveSize"] = city.metaDictionary[@"archiveSize"];
        city.updatedMeta = [updatedMeta copy];
    }
    
    return [mCitiesMeta copy];
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
        
        for (MFACity *city in _loadedCities) {
            if (city.metaDictionary[@"archiveSize"] == nil) {
                [self calculateArchiveSizeForCity:city];
            }
        }
    }
    
    return _loadedCities;
}

- (void)processCityMeta:(NSDictionary *)selectedCity
         withCompletion:(void (^)(void))completionBlock
                  error:(void (^)(NSError *))errorBlock
{
    self.completionBlock = completionBlock;
    self.errorBlock = errorBlock;
    
    RACSignal *downloadProgress = [self.archiveService getCityFilesForMetadata:selectedCity
                                                                    completion:^(NSString *path, NSError *error)
    {
        self.downloadProgress = nil;
        
        // we are updating city that was already downloaded
        if ([selectedCity[@"hasUpdate"] boolValue] == YES) {
            // delete old files
            MFACity *city = [MFACity cityWithIdentifier:selectedCity[@"path"]];
            NSURL *oldFilesPath = [city.metaDictionary filesDirectory];
            [[NSFileManager defaultManager] removeItemAtURL:oldFilesPath error:nil];
        }
        
        NSMutableDictionary *meta = [selectedCity mutableCopy];
        meta[@"archiveSize"] = [self sizeOfFolder:path];
        
        if (error) {
            [self handleError:error];
        }
        else {
            //    dispatch_async(dispatch_get_main_queue(), ^{
            //        [SVProgressHUD dismiss];
            //    });
            
            NSManagedObjectContext *moc =
            [[UIApplication sharedApplication].delegate performSelector:@selector(managedObjectContext)];
            
            MFACityDataParser *parser =
            [[MFACityDataParser alloc] initWithCityMeta:meta
                                              pathToCSV:path
                                   managedObjectContext:moc
                                               delegate:self];
            
            //    dispatch_async(dispatch_get_main_queue(), ^{
            //        [SVProgressHUD showProgress:0.0
            //                             status:@"Обработка данных"
            //                           maskType:SVProgressHUDMaskTypeBlack];
            //    });
            
            self.parser = parser;
            dispatch_async(dispatch_get_main_queue(), ^{
                [parser start];
            });
        }
    }];
    
    [downloadProgress subscribeNext:^(NSNumber *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:progress.floatValue
                                 status:@"Загружаются данные города"
                               maskType:SVProgressHUDMaskTypeBlack];
        });
    } completed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
    
    self.downloadProgress = downloadProgress;
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

- (void)deleteCityAtIndex:(NSUInteger)index
{
    MFACity *city = self.loadedCities[index];
    if (city == nil) {
        return;
    }
    
    NSError *error = nil;
    NSURL *cityFilesURL = [((MFACityMeta *)city.metaDictionary) filesDirectory];
    [[NSFileManager defaultManager] removeItemAtPath:cityFilesURL.path error:&error];
     
    if (!error) {
       [self.managedObjectContext deleteObject:city];
       [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:nil];
    }
    
    self.loadedCities = nil; // force reload on next access
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
    self.selectedCity = city;
    self.parser = nil;

    [self changeCity:city];

    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock();
            self.completionBlock = nil;
        });
    }
}

- (void)changeCity:(MFACity *)city
{
    [[NSUserDefaults standardUserDefaults] setObject:city.metaDictionary forKey:@"MFA_CURRENT_CITY"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFA_CHANGE_CITY" object:nil];
}

- (void)downloadCity:(MFACityMeta *)meta completion:(void (^)())completionBlock
{
    [SVProgressHUD showWithStatus:@"Загружаются данные города" maskType:SVProgressHUDMaskTypeBlack];
    
    [self processCityMeta:meta withCompletion:^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Данные загружены" maskType:SVProgressHUDMaskTypeBlack];
        
        if (completionBlock) {
            self.loadedCities = nil; // reload lazily
            self.cities = [self checkForUpdates:self.cities];
            completionBlock();
        }
    }
                    error:^(NSError *error) {
                        [SVProgressHUD dismiss];
                        [self showErrorMessage];
                    }];
}

- (void)showErrorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                       message:@"Произошла ошибка при загрузке данных. Попробуйте повторить операцию или обратитесь в поддержку"
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
        
        [alert show];
    });
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
        MFACity *city = self.loadedCities[row];
        if (city.updatedMeta != nil) {
            return city.updatedMeta;
        }
        
        return city.metaDictionary;
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

#pragma mark - Helpers

- (void)calculateArchiveSizeForCity:(MFACity *)city
{
    MFACityMeta *meta = city.metaDictionary;
    NSMutableDictionary *dict = [meta mutableCopy];
    dict[@"archiveSize"] = [self sizeOfFolder:meta.filesDirectory.path];
    
    city.metaDictionary = [dict copy];
}

- (NSString *)sizeOfFolder:(NSString *)folderPath
{
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long int folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    
    //This line will give you formatted size from bytes ....
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}


@end