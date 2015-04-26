//
//  MFARouteTableViewStationCell.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFALineColorView.h"

@class MFAStation, MFARouteTableViewStationCell;

@protocol MFARouteTableViewStationCellDelegate <NSObject>

- (void)stationCellDidRequestMap:(MFARouteTableViewStationCell *)cell;
- (void)stationCellDidRequestScheme:(MFARouteTableViewStationCell *)cell;

@end


@interface MFARouteTableViewStationCell : UITableViewCell

@property (nonatomic, strong) MFAStation *station;

@property (nonatomic, weak) IBOutlet MFALineColorView *lineColorView;
@property (nonatomic, weak) IBOutlet UILabel *stationNameLabel;

@property (nonatomic, weak) IBOutlet UIButton *mapButton;
@property (nonatomic, weak) IBOutlet UIButton *schemeButton;

@property (nonatomic, weak) id<MFARouteTableViewStationCellDelegate> delegate;

@end
