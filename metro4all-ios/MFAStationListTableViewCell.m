//
//  MFAStationListTableViewCell.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFAStationListTableViewCell.h"
#import "MFAStation.h"
#import "MFALine.h"

@interface MFAStationListTableViewCell ()

@property (nonatomic, weak) IBOutlet UIView *lineColorView;
@property (nonatomic, weak) IBOutlet UILabel *stationTitleLabel;

@end

@implementation MFAStationListTableViewCell

- (void)awakeFromNib {
    // make round line color indicator
    self.lineColorView.layer.cornerRadius = self.lineColorView.frame.size.width / 2;
}

- (void)setStation:(MFAStation *)station
{
    _station = station;
    
    self.lineColorView.backgroundColor = self.station.line.color;
    self.stationTitleLabel.text = self.station.nameString;
}

@end

@implementation MFAStationListSelectedTableViewCell

- (IBAction)showMap:(id)sender
{
    [self.delegate stationCellDidRequestMap:self];
}

- (IBAction)showScheme:(id)sender
{
    [self.delegate stationCellDidRequestScheme:self];
}

@end
