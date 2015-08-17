//
//  MFAMenuContainerViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 28/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <OHAlertView/OHAlertView.h>

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
    MFASideMenuViewController *leftMenuController =
        (MFASideMenuViewController *)[MFAStoryboardProxy leftMenuViewController];
    leftMenuController.delegate = self;
    self.leftMenuViewController = leftMenuController;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.mainViewController.navigationItem.leftBarButtonItem = self.menuButton;
    
    self.contentViewController = navController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentViewInPortraitOffsetCenterX = 190.0f - CGRectGetWidth(self.view.frame)/2;
}

- (UIViewController *)selectCityViewController
{
    if (_selectCityViewController == nil) {
        MFASelectCityViewModel *viewModel = [[MFASelectCityViewModel alloc] init];
        
        MFASelectCityViewController *selectCityController =
            (MFASelectCityViewController *)[MFAStoryboardProxy selectCityViewController];
        
        selectCityController.viewModel = viewModel;
        
        self.selectCityViewController = selectCityController;
    }
    
    return _selectCityViewController;
}

- (UIViewController *)mainViewController
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

- (UIViewController *)stationsListViewController
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
        UIBarButtonItem *changeCityButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Menu", nil)
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
         
        case 1: {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.stationsListViewController];
            self.stationsListViewController.navigationItem.leftBarButtonItem = self.menuButton;
            [self setContentViewController:navController animated:YES];
            break;
        }
            
        case 2: {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.selectCityViewController];
            self.selectCityViewController.navigationItem.leftBarButtonItem = self.menuButton;
            
            [self setContentViewController:navController animated:YES];
            break;
        }
            
        case 3: {
            [self performSegueWithIdentifier:@"feedback" sender:nil];
            break;
        }
            
        case 99: {
            NSURL *infoUrl = [NSURL URLWithString:@"http://metro4all.org"];
            if ([[UIApplication sharedApplication] canOpenURL:infoUrl]) {
                [OHAlertView showAlertWithTitle:@"merto4all.org"
                                        message:NSLocalizedString(@"Do you want to browse \"http://metro4all.org\" in Safari?", nil)
                                   cancelButton:NSLocalizedString(@"No", nil)
                                       okButton:NSLocalizedString(@"Yes", nil)
                                  buttonHandler:^(OHAlertView *alert, NSInteger buttonIndex) {
                                      if (buttonIndex != [(UIAlertView *)alert cancelButtonIndex]) {
                                          [[UIApplication sharedApplication] openURL:infoUrl];
                                      }
                                  }];
            }
        }
        default:
            break;
    }
    
    [self hideMenuViewController];
}

- (IBAction)unwindToMain:(UIStoryboardSegue *)segue
{
    
}

@end
