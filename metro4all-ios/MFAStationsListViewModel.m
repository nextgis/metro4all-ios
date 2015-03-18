//
//  MFAStationsListViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFAStationsListViewModel.h"
#import "MFACity.h"

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
    }
    
    return self;
}

- (NSArray *)fetchStationsForCity:(MFACity *)city searchString:(NSString *)searchString
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:city.managedObjectContext];

    if (searchString) {
        // case-insensitive, diacritic-insensitive contain
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
    }

    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[ nameSortDescriptor ]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [city.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

- (NSString *)screenTitle
{
    return self.city.name;
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
    
    if (searchString.length == 0) {
        self.searchResults = self.allStations;
    }
    
    self.searchResults = [self fetchStationsForCity:self.city searchString:searchString];
}

@end
