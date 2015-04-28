//
//  MFARouteTableViewInterchangeCell.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFAInterchangeLineColorView.h"
#import "MFARouteTableViewStationCell.h"

@class MFAInterchange;

@interface MFARouteTableViewInterchangeCell : MFARouteTableViewCell

@property (nonatomic, weak) MFAInterchange *interchange;

@property (nonatomic, weak) IBOutlet MFAInterchangeLineColorView *interchangeColorView;
@property (nonatomic, weak) IBOutlet UILabel *stationFromNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *stationToNameLabel;

@end
