//
//  MFASideMenuViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 28/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFASideMenuViewController.h"
#import "MFAMenuContainerViewController.h"

#import <PureLayout/PureLayout.h>

@interface MFASideMenuViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@end

@implementation MFASideMenuViewController

- (IBAction)menuItem:(UIButton *)sender
{
    [self.delegate sideMenu:self didSelectItem:sender.tag];
}
@end
