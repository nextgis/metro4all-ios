//
//  MFAStationsListViewController.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFAStationsListViewModel.h"

@class MFAStationsListViewController, MFAStation;

@protocol MFAStationListDelegate <NSObject>

- (void)stationList:(MFAStationsListViewController *)controller
   didSelectStation:(MFAStation *)station;

@end

@interface MFAStationsListViewController : UIViewController

@property (nonatomic, strong) MFAStationsListViewModel *viewModel;
@property (nonatomic, weak) id<MFAStationListDelegate> delegate;
@property (nonatomic) BOOL fromStation;

@end
