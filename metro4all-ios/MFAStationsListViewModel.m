//
//  MFAStationsListViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "MFAStationsListViewModel.h"
#import "MFACity.h"
#import "MFAStation.h"

@interface MFAStationsListViewModel ()

@property (nonatomic, strong) MFACity *city;

@property (nonatomic, strong, readwrite) NSArray *searchResults;

@property (nonatomic, strong, readwrite) NSArray *allStations;

@end

@implementation MFAStationsListViewModel

- (instancetype)initWithCity:(MFACity *)city
{
    self = [super init];
    if (self) {
        self.city = city;
        self.allStations = [self fetchStationsForCity:city searchString:nil];
        self.searchResults = self.allStations;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCity:)
                                                     name:@"MFA_CHANGE_CITY" object:nil];
    }
    
    return self;
}

- (NSArray *)fetchStationsForCity:(MFACity *)city searchString:(NSString *)searchString
{
    NSArray *fetchedObjects = [MFAStation MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"city == %@", city]];
    
    NSArray *filtered = nil;
    if (searchString) {
        filtered = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nameString CONTAINS[cd] %@", searchString]];
    }
    else {
        filtered = fetchedObjects;
    }
    
    NSArray *sorted = [filtered sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"nameString" ascending:YES]]];
    return sorted;
}

- (NSString *)screenTitle
{
    return self.city.nameString;
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
    
    if (searchString.length == 0) {
        self.searchResults = self.allStations;
    }
    
    self.searchResults = [self fetchStationsForCity:self.city searchString:searchString];
}

- (UIViewController *)selectCityViewController
{
    return [((AppDelegate *)[UIApplication sharedApplication].delegate) setupSelectCityController];
}

- (void)changeCity:(NSNotification *)note
{
    NSDictionary *currentCityMeta = [[NSUserDefaults standardUserDefaults] objectForKey:@"MFA_CURRENT_CITY"];
    
    MFACity *city = [MFACity cityWithIdentifier:currentCityMeta[@"path"]];
    
    if (!city) {
        
    }
    else {
        self.city = city;
        self.allStations = [self fetchStationsForCity:self.city searchString:nil];
        self.searchResults = self.allStations;
    }
}
@end
