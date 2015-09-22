//
//  MFASideMenuViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 28/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFASideMenuViewController.h"
#import "MFAMenuContainerViewController.h"
#import "NSString+Utils.h"

#import <PureLayout/PureLayout.h>

@interface MFASideMenuViewController ()

@property (weak, nonatomic) IBOutlet UIButton *findRouteButton;
@property (weak, nonatomic) IBOutlet UIButton *allStationsButton;
@property (weak, nonatomic) IBOutlet UIButton *selectCityButton;
@property (weak, nonatomic) IBOutlet UIButton *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;

@end

@implementation MFASideMenuViewController

- (IBAction)menuItem:(UIButton *)sender
{
    [self.delegate sideMenu:self didSelectItem:sender.tag];
}

- (void)viewDidLoad
{
    // Localize
    [self.findRouteButton setTitle:NSLocalizedString(@"Find a route", nil)
                          forState:UIControlStateNormal];
    [self.allStationsButton setTitle:NSLocalizedString(@"All stations", nil)
                            forState:UIControlStateNormal];
    [self.selectCityButton setTitle:NSLocalizedString(@"Change city", nil)
                           forState:UIControlStateNormal];
    [self.feedbackButton setTitle:NSLocalizedString(@"Send feedback", nil)
                           forState:UIControlStateNormal];
    
    UIImage *logo = nil;
    NSString *lang = [[NSLocale preferredLanguages].firstObject substringToIndex:2];
    if ([lang isEqualToString:@"ru"]) {
        logo = [UIImage imageNamed:@"logo_rus"];
    } else if ([lang isEqualToString:@"uk"]) {
        logo = [UIImage imageNamed:@"logo_ukr"];
    } else {
        logo = [UIImage imageNamed:@"logo_en"];
    }

    [self.logoImageView setImage:logo forState:UIControlStateNormal];
}

@end
