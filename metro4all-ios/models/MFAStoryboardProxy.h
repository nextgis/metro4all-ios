//
//  MFAStoryboardProxy.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MFAStoryboardProxy : NSObject

+ (UIStoryboard *)mainStoryboard;

+ (UIViewController *)selectCityViewController;
+ (UIViewController *)stationsListViewController;
+ (UIViewController *)stationMapViewController;
+ (UIViewController *)legendViewController;
+ (UIViewController *)selectStationViewController;
+ (UIViewController *)sideMenuViewController;
+ (UIViewController *)menuContainerViewController;

@end
