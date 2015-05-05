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
                    self.cities = citiesMeta;
                
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

- (void)processCityMeta:(NSDictionary *)selectedCity withCompletion:(void (^)(void))completionBlock error:(void (^)(NSError *))errorBlock
{
    self.completionBlock = completionBlock;
    self.errorBlock = errorBlock;
    
    [self.archiveService getCityFilesForMetadata:selectedCity completion:^(NSString *path, NSError *error) {
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
            [[MFACityDataParser alloc] initWithCityMeta:selectedCity
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
    
    [self.managedObjectContext deleteObject:city];
    [self.managedObjectContext save:nil];
    
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