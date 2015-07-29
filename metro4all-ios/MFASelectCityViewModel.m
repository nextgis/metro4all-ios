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

#import "MFACityManager.h"

#import "MFASelectCityViewModel.h"
#import "MFACityDataParser.h"
#import "NSDictionary+CityMeta.h"

@interface MFASelectCityViewModel () <MFACityDataParserDelegate>

@property (nonatomic, strong) MFACityDataParser *parser;
@property (nonatomic, strong) void (^completionBlock)(void);
@property (nonatomic, strong) void (^errorBlock)(NSError *);

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
    MFACity *city = [MFACityManager sharedManager].downloadedCities[index];
    NSAssert(city, @"city to delete not found");

    [[MFACityManager sharedManager] deleteCity:city];
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

- (void)downloadCityAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)())completionBlock
{
    if (indexPath.section == 1 || self.numberOfSections == 1) {
        MFACityMeta *selectedCity = [self viewModelForRow:indexPath.row inSection:indexPath.section];
        [self downloadCity:selectedCity completion:completionBlock];
    }
    else {
        [self changeCity:[MFACityManager sharedManager].downloadedCities[indexPath.row]];
        completionBlock();
    }
}

- (void)downloadCity:(MFACityMeta *)selectedCity completion:(void (^)())completionBlock
{
    [SVProgressHUD showWithStatus:@"Загружаются данные города" maskType:SVProgressHUDMaskTypeBlack];
    
    self.completionBlock = ^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Данные загружены" maskType:SVProgressHUDMaskTypeBlack];
        
        if (completionBlock) {
            completionBlock();
        };
    };
    
    __weak typeof(self) welf = self;
    self.errorBlock = ^(NSError *error) {
        [SVProgressHUD dismiss];
        [welf showErrorMessage];
    };
    
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
                                                       
                                                       MFACityDataParser *parser =
                                                       [[MFACityDataParser alloc] initWithCityMeta:selectedCity
                                                                                          delegate:self];
                                                       
                                                       self.parser = parser;
                                                       [parser start];
                                                       
                                                       [SVProgressHUD dismiss];
                                                   } error:^(NSError *error) {
                                                       [SVProgressHUD dismiss];
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
    if ([MFACityManager sharedManager].downloadedCities.count > 0) {
        return 2;
    }
    
    return 1;
}

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section
{
    if (section == 1 || self.numberOfSections == 1) {
        NSUInteger rows = [MFACityManager sharedManager].availableCities.count;
//        NSLog(@"# there're %tu rows in section %td", rows, section);
        return rows;
    }
    else {
        return [MFACityManager sharedManager].downloadedCities.count;
    }
}

- (NSDictionary *)viewModelForRow:(NSUInteger)row inSection:(NSUInteger)section
{
    if (section == 1 || self.numberOfSections == 1) {
        return [MFACityManager sharedManager].availableCities[row];
    }
    else {
        MFACity *city = [MFACityManager sharedManager].downloadedCities[row];
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

- (BOOL)hasData
{
    return [MFACityManager sharedManager].availableCities.count > 0;
}

@end