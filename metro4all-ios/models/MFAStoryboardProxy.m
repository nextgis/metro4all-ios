//
//  MFAStoryboardProxy.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFAStoryboardProxy.h"

static UIStoryboard *mainStoryboard = nil;

@implementation MFAStoryboardProxy

+ (UIStoryboard *)mainStoryboard
{
    if (!mainStoryboard) {
        id storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSAssert(storyboard != nil, @"Failed to get storyboard named 'Main.storyboard'");
        
        mainStoryboard = storyboard;
    }
    
    return mainStoryboard;
}

+ (UIViewController *)selectCityViewController
{
    return [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"MFA_selectCityViewController"];
}

+ (UIViewController *)stationsListViewController
{
    return [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"MFA_stationsListViewController"];
}

+ (UIViewController *)stationMapViewController
{
    return [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"MFA_stationMapViewController"];
}

+ (UIViewController *)legendViewController
{
    return [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"MFA_legendViewController"];
}

@end
