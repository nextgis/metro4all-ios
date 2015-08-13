//
//  MFAPickPointViewController.h
//  metro4all-ios
//
//  Created by marvin on 13.08.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFAStation.h"

@class MFAPickPointViewController;

@protocol MFAPickPointDelegate <NSObject>

- (void)pickPointController:(MFAPickPointViewController *)controller
         didFinishWithImage:(UIImage *)image;

@end

@interface MFAPickPointViewController : UIViewController

@property (nonatomic, strong) MFAStation *station;
@property (nonatomic, weak) id<MFAPickPointDelegate> delegate;

@end
