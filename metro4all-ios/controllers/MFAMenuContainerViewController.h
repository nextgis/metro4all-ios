//
//  MFAMenuContainerViewController.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 28/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RESideMenu/RESideMenu.h>
#import "MFASideMenuViewController.h"

@interface MFAMenuContainerViewController : RESideMenu <MFASideMenuDelegate>

@property (nonatomic, readonly) UIViewController *selectCityViewController;
@property (nonatomic, readonly) UIViewController *mainViewController;
@property (nonatomic, readonly) UIViewController *stationsListViewController;

@end
