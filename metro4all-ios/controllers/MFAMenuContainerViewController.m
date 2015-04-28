//
//  MFAMenuContainerViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 28/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "AppDelegate.h"

#import "MFAMenuContainerViewController.h"
#import "MFAStoryboardProxy.h"

#import "MFASideMenuViewController.h"
#import "MFAStationsListViewModel.h"
#import "MFAStationsListViewController.h"
#import "MFASelectCityViewModel.h"
#import "MFASelectCityViewController.h"
#import "MFASelectStationViewController.h"

@class MFACity;

@interface MFAMenuContainerViewController () <MFASideMenuDelegate>

@property (nonatomic, strong) MFASelectStationViewController *mainViewController;
@property (nonatomic, strong) MFASelectCityViewController *selectCityViewController;
@property (nonatomic, strong) MFAStationsListViewController *stationsListViewController;

@end

@implementation MFAMenuContainerViewController

- (void)awakeFromNib
{
    MFASideMenuViewController *sideMenuController =
        (MFASideMenuViewController *)[MFAStoryboardProxy sideMenuViewController];
    
    sideMenuController.delegate = self;
    
    self.leftMenuViewController = sideMenuController;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.contentViewController = navController;
}

- (MFASelectCityViewController *)selectCityViewController
{
    if (_selectCityViewController == nil) {
        _selectCityViewController = [(AppDelegate *)[UIApplication sharedApplication].delegate setupSelectCityController];
    }
    
    return _selectCityViewController;
}

- (MFASelectStationViewController *)mainViewController
{
    if (_mainViewController == nil) {
        MFACity *city = [(AppDelegate *)[UIApplication sharedApplication].delegate currentCity];
        
        MFASelectStationViewController *selectStation =
            (MFASelectStationViewController *)[MFAStoryboardProxy selectStationViewController];
        selectStation.city = city;

        _mainViewController = selectStation;
    }
    
    return _mainViewController;
}

- (MFAStationsListViewController *)stationsListViewController
{
    if (_stationsListViewController == nil) {
        MFACity *city = [(AppDelegate *)[UIApplication sharedApplication].delegate currentCity];
        
        MFAStationsListViewModel *viewModel = [[MFAStationsListViewModel alloc] initWithCity:city];
        MFAStationsListViewController *viewController = (MFAStationsListViewController *)[MFAStoryboardProxy stationsListViewController];
        viewController.viewModel = viewModel;
        
        _stationsListViewController = viewController;
    }
    
    return _stationsListViewController;
}

- (void)sideMenu:(MFASideMenuViewController *)menuController didSelectItem:(NSUInteger)item
{
    switch (item) {
        case 0: {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
            [self setContentViewController:navController animated:YES];
            break;
        }
            
        case 2:
            [self setContentViewController:self.selectCityViewController animated:YES];
            break;
            
        case 1: {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.stationsListViewController];
            [self setContentViewController:navController animated:YES];
            break;
        }
            
        default:
            break;
    }
    
    [self hideMenuViewController];
}

@end
