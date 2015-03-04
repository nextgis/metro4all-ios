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
@property (nonatomic, strong, readwrite) NSArray *stations;
@property (nonatomic, strong, readwrite) NSArray *lines;

@end

@implementation MFAStationsListViewModel

- (instancetype)initWithCity:(MFACity *)city
{
    self = [super init];
    if (self) {
        self.city = city;
    }
    
    return self;
}

- (void)setCity:(MFACity *)city
{
    _city = city;
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.stations = [[city.stations allObjects] sortedArrayUsingDescriptors:@[ nameSortDescriptor ]];
    self.lines = [[city.lines allObjects] sortedArrayUsingDescriptors:@[ nameSortDescriptor ]];
}

- (NSString *)cityName
{
    return self.city.name;
}

@end
