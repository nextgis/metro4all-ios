//
//  MFASelectCityViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "AppDelegate.h"

#import <MagicalRecord/MagicalRecord.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SSZipArchive/SSZipArchive.h>

#import "MFASelectCityViewModel.h"
#import "MFACityDataParser.h"
#import "MFACity.h"
#import "NSDictionary+CityMeta.h"
#import "MFACityManager.h"

@interface MFASelectCityViewModel () <MFACityDataParserDelegate>

@property (nonatomic, strong) MFACityDataParser *parser;
@property (nonatomic, strong) void (^completionBlock)(void);
@property (nonatomic, strong) void (^errorBlock)(NSError *);

/// Cities that are already downloaded on the device (MFACity *)
@property (nonatomic, strong, readwrite) NSArray *loadedCities;

/// Cities loaded from server (NSDictionary * meta)
@property (nonatomic, strong, readwrite) NSArray *cities;

@property (nonatomic, strong, readwrite) MFACity *selectedCity;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) RACSignal *downloadProgress;

@end

@implementation MFASelectCityViewModel
@synthesize loadMetaFromServerCommand = _loadMetaFromServerCommand;

- (NSManagedObjectContext *)managedObjectContext
{
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

- (RACCommand *)loadMetaFromServerCommand
{
    if (!_loadMetaFromServerCommand) {
        _loadMetaFromServerCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            RACSignal *loadMetaSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler mainThreadScheduler] block:^(id<RACSubscriber> subscriber) {                
                [SVProgressHUD showWithStatus:@"Загружаю список городов"
                                     maskType:SVProgressHUDMaskTypeBlack];
                
                [[MFACityManager sharedManager] updateMetaWithSuccess:^(NSArray *meta) {
                    [SVProgressHUD dismiss];
                    
                    self.cities = meta;
                    [subscriber sendCompleted];
                } error:^(NSError *error) {
                    [SVProgressHUD dismiss];
                    
                    [subscriber sendError:[NSError errorWithDomain:@"org.metro4all.metro4all-ios"
                                                              code:1
                                                          userInfo:@{ NSLocalizedDescriptionKey : @"Failed to get list of available cities" }]];
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

- (void)processCityMeta:(MFACityMeta *)selectedCity
         withCompletion:(void (^)(void))completionBlock
                  error:(void (^)(NSError *))errorBlock
{
    self.completionBlock = completionBlock;
    self.errorBlock = errorBlock;

    [[MFACityManager sharedManager] downloadCityWithIdentifier:selectedCity[@"path"]
                                                   unzipToPath:[selectedCity filesDirectory].path progress:^(float progress) {
        [SVProgressHUD showProgress:progress
                             status:@"Загружаются данные города"
                           maskType:SVProgressHUDMaskTypeBlack];
    } success:^{
        // we are updating city that was already downloaded
        if ([selectedCity[@"hasUpdate"] boolValue] == YES) {
            // delete old files
            MFACity *city = [MFACity cityWithIdentifier:selectedCity[@"path"]];
            NSURL *oldFilesPath = [city.metaDictionary filesDirectory];
            [[NSFileManager defaultManager] removeItemAtURL:oldFilesPath error:nil];
        }
        
        NSManagedObjectContext *moc =
        [[UIApplication sharedApplication].delegate performSelector:@selector(managedObjectContext)];
        
        MFACityDataParser *parser =
            [[MFACityDataParser alloc] initWithCityMeta:selectedCity
                                   managedObjectContext:moc
                                               delegate:self];
            
        self.parser = parser;
        [parser start];
        
        [SVProgressHUD dismiss];
    } error:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
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

- (void)cityDataParser:(MFACityDataParser *)parser didFinishParsingCityWithIdentifier:(NSString *)cityIdentifier
{
    self.selectedCity = [MFACity cityWithIdentifier:cityIdentifier];
    self.parser = nil;

    [self changeCity:self.selectedCity];

    if (self.completionBlock) {
        self.completionBlock();
        self.completionBlock = nil;
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

@end