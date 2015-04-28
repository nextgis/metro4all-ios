//
//  MFASideMenuViewController.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 28/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFASideMenuViewController;

@protocol MFASideMenuDelegate <NSObject>

- (void)sideMenu:(MFASideMenuViewController *)menuController didSelectItem:(NSUInteger)item;

@end

@interface MFASideMenuViewController : UITableViewController
@property (nonatomic, weak) id<MFASideMenuDelegate> delegate;
@end
