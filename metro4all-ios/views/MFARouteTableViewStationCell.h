//
//  MFARouteTableViewStationCell.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFALineColorView.h"

@class MFAStation;

@interface MFARouteTableViewStationCell : UITableViewCell

@property (nonatomic, strong) MFAStation *station;
@property (nonatomic, weak) IBOutlet MFALineColorView *lineColorView;
@property (nonatomic, weak) IBOutlet UILabel *stationNameLabel;

@end
