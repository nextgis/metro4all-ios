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

#import "MFAStationsListViewModel.h"
#import "MFAStationsListViewController.h"
#import "MFASelectCityViewModel.h"
#import "MFASelectCityViewController.h"
#import "MFASelectStationViewController.h"

@class MFACity;

@interface MFAMenuContainerViewController ()

@property (nonatomic, strong) MFASelectStationViewController *mainViewController;
@property (nonatomic, strong) MFASelectCityViewController *selectCityViewController;
@property (nonatomic, strong) MFAStationsListViewController *stationsListViewController;
@property (nonatomic, strong) UIBarButtonItem *menuButton;

@end

@implementation MFAMenuContainerViewController

- (void)awakeFromNib
{
    MFASideMenuViewController *sideMenuController =
        (MFASideMenuViewController *)[MFAStoryboardProxy sideMenuViewController];
    
    sideMenuController.delegate = self;
    
    self.leftMenuViewController = sideMenuController;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.mainViewController.navigationItem.leftBarButtonItem = self.menuButton;
    
    self.contentViewController = navController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentViewInPortraitOffsetCenterX = 190.0f - CGRectGetWidth(self.view.frame)/2;
}

- (MFASelectCityViewController *)selectCityViewController
{
    if (_selectCityViewController == nil) {
        MFACityArchiveService *archiveService =
            [[MFACityArchiveService alloc] initWithBaseURL:[NSURL URLWithString:@"http://metro4all.org/data/v2.7/"]];
        
        MFASelectCityViewModel *viewModel =
            [[MFASelectCityViewModel alloc] initWithCityArchiveService:archiveService];
        
        MFASelectCityViewController *selectCityController =
            (MFASelectCityViewController *)[MFAStoryboardProxy selectCityViewController];
        
        selectCityController.viewModel = viewModel;
        
        self.selectCityViewController = selectCityController;
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

- (UIBarButtonItem *)menuButton
{
    if (_menuButton == nil) {
        UIBarButtonItem *changeCityButton = [[UIBarButtonItem alloc] initWithTitle:@"Меню"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController)];
        
        _menuButton = changeCityButton;
    }
    
    return _menuButton;
}


- (void)sideMenu:(MFASideMenuViewController *)menuController didSelectItem:(NSUInteger)item
{
    switch (item) {
        case 0: {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
            self.mainViewController.navigationItem.leftBarButtonItem = self.menuButton;
            [self setContentViewController:navController animated:YES];
            break;
        }
            
        case 2: {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.selectCityViewController];
            self.selectCityViewController.navigationItem.leftBarButtonItem = self.menuButton;
            
            [self setContentViewController:navController animated:YES];
            break;
        }
            
        case 1: {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.stationsListViewController];
            self.stationsListViewController.navigationItem.leftBarButtonItem = self.menuButton;
            [self setContentViewController:navController animated:YES];
            break;
        }
            
        default:
            break;
    }
    
    [self hideMenuViewController];
}

@end
