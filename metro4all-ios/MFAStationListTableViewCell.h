//
//  MFAStationListTableViewCell.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFAStation, MFAStationListTableViewCell;

@protocol MFAStationListTableViewCellDelegate <NSObject>

- (void)stationCellDidRequestMap:(MFAStationListTableViewCell *)cell;
- (void)stationCellDidRequestScheme:(MFAStationListTableViewCell *)cell;

@end

@interface MFAStationListTableViewCell : UITableViewCell

@property (nonatomic, strong) MFAStation *station;

@end

@interface MFAStationListSelectedTableViewCell : MFAStationListTableViewCell

@property (nonatomic, weak) id<MFAStationListTableViewCellDelegate> delegate;

@end
