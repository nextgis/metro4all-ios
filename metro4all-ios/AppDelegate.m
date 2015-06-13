
//
//  AppDelegate.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "AppDelegate.h"

#import "MFACityArchiveService.h"

#import "MFAStoryboardProxy.h"

#import "MFACity.h"

#import "MFASelectCityViewController.h"
#import "MFASelectCityViewModel.h"

#import "NSDictionary+CityMeta.h"
#import "MFACityDataParser.h"

#import "MFASelectStationViewController.h"
#import "MFAMenuContainerViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)setupAppearance
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0/255 green:179.0/255 blue:212.0/255 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f]
                                                           }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (UIViewController *)setupSelectCityController
{
    MFACityArchiveService *archiveService =
        [[MFACityArchiveService alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost:8000/"]];
    
    MFASelectCityViewModel *viewModel =
        [[MFASelectCityViewModel alloc] initWithCityArchiveService:archiveService];
    
    MFASelectCityViewController *selectCityController =
        (MFASelectCityViewController *)[MFAStoryboardProxy selectCityViewController];
    
    selectCityController.viewModel = viewModel;
    
    UINavigationController *navController =
        [[UINavigationController alloc] initWithRootViewController:selectCityController];
    
    return navController;
}

- (MFACity *)currentCity
{
    NSDictionary *currentCityMeta = [[NSUserDefaults standardUserDefaults] objectForKey:@"MFA_CURRENT_CITY"];
    MFACity *city = [MFACity cityWithIdentifier:currentCityMeta[@"path"]];
    return city;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"c43619aaae8fac9a0428b7b54a32e0a00aa223f7"];
    
    [self setupAppearance];
    [self disableIcloudBackup];
    
    id storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"data/metro4all_ios.sqlite"];
    
    if (![NSPersistentStoreCoordinator MR_defaultStoreCoordinator]) {

        NSManagedObjectModel *model = [NSManagedObjectModel MR_defaultManagedObjectModel];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSError *error = nil;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil
                                                               URL:storeUrl
                                                           options:nil
                                                             error:&error];
        
        BOOL isMigrationError = [error code] == NSPersistentStoreIncompatibleVersionHashError || [error code] == NSMigrationMissingSourceModelError;
        
        if (!store && [[error domain] isEqualToString:NSCocoaErrorDomain] && isMigrationError) {
            [self recreatePersistentStore];
        }
        else {
            [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:psc];
            [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:psc];
        }
    }

    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIViewController *rootViewController = nil;
    
    if ([self currentCity] == nil) {
        // no stored city or cannot fetch city from coredata
        rootViewController = [self setupSelectCityController];
    }
    else {
        // we do know that there's a city that can be used
        MFAMenuContainerViewController *menuContainer =
            (MFAMenuContainerViewController *)[MFAStoryboardProxy menuContainerViewController];
        
        rootViewController = menuContainer;
    }
    
    window.rootViewController = rootViewController;
    [window addSubview:rootViewController.view];
    [window makeKeyAndVisible];
    
    self.window = window; // store Window object so it's not released
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext *)managedObjectContext {
    return [NSManagedObjectContext MR_defaultContext];
}

- (NSPersistentStoreCoordinator *)recreatePersistentStore
{
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"data/metro4all_ios.sqlite"];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    
    NSError *error = nil;
    NSManagedObjectModel *model = [NSManagedObjectModel MR_defaultManagedObjectModel];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                         configuration:nil
                                                                   URL:storeURL
                                                               options:nil
                                                                 error:&error];
    
    if (store == nil) {
        NSLog(@"failed to recreate persistent store, abort");
        NSLog(@"%@", error.localizedDescription);
        
        abort();
    }
    
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:coordinator];
    [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:coordinator];
    
    NSURL *dataUrl = [MFACityMeta metaJsonFileURL];
    NSData *jsonData = [NSData dataWithContentsOfURL:dataUrl];
    
    NSArray *cities = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:0 error:nil][@"packages"];
    
    for (MFACityMeta *meta in cities) {
        NSURL *csvDir = [meta filesDirectory];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:csvDir.path]) {
            MFACityDataParser *parser = [[MFACityDataParser alloc] initWithCityMeta:meta
                                                                          pathToCSV:csvDir.path
                                                               managedObjectContext:self.managedObjectContext
                                                                           delegate:nil];
            
            [parser parseSync];
        }
    }
    
    return coordinator;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)disableIcloudBackup 
{
    NSString *docsDir;
    NSArray *dirPaths;
    NSURL * finalURL;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    finalURL = [[NSURL fileURLWithPath:docsDir] URLByAppendingPathComponent:@"data"];

    // create data dir if needed
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalURL.path isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:finalURL.path
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    
    NSError *error = nil;
    
    BOOL success = [finalURL setResourceValue: [NSNumber numberWithBool: YES]
                                       forKey: NSURLIsExcludedFromBackupKey
                                        error: &error];
    
    if (!success){
        NSLog(@"Error excluding %@ from backup %@", [finalURL lastPathComponent], error);
    }
}

@end
