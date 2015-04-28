//
//  MFAMenuContainerViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 28/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFAMenuContainerViewController.h"
#import "MFAStoryboardProxy.h"
#import "MFASideMenuViewController.h"

@interface MFAMenuContainerViewController () <MFASideMenuDelegate>

@end

@implementation MFAMenuContainerViewController

- (void)awakeFromNib
{
    MFASideMenuViewController *sideMenuController =
        (MFASideMenuViewController *)[MFAStoryboardProxy sideMenuViewController];
    
    sideMenuController.delegate = self;
    
    self.leftMenuViewController = sideMenuController;
    self.contentViewController = [MFAStoryboardProxy selectStationViewController];
}

- (void)sideMenu:(MFASideMenuViewController *)menuController didSelectItem:(NSUInteger)item
{
    NSLog(@"%d", item);
}

@end
