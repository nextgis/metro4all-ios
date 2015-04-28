//
//  MFARouteTableViewStationCell.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFALineColorView.h"

@class MFAStation, MFARouteTableViewCell;

@protocol MFARouteTableViewCellDelegate <NSObject>

- (void)stationCellDidRequestMap:(MFARouteTableViewCell *)cell;
- (void)stationCellDidRequestScheme:(MFARouteTableViewCell *)cell;

@end

@interface MFARouteTableViewCell : UITableViewCell

@property (nonatomic, strong) MFAStation *station;
@property (nonatomic, weak) id<MFARouteTableViewCellDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *schemeButton;

@end

@interface MFARouteTableViewStationCell : MFARouteTableViewCell

@property (nonatomic, weak) IBOutlet MFALineColorView *lineColorView;
@property (nonatomic, weak) IBOutlet UILabel *stationNameLabel;

@end
