//
//  MFARouteTableViewStationCell.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFARouteTableViewStationCell.h"

@implementation MFARouteTableViewStationCell

- (void)awakeFromNib
{
    self.mapButton.hidden = YES;
    self.schemeButton.hidden = YES;
}

- (void)prepareForReuse
{
    self.lineColorView.isLastStation = NO;
    self.lineColorView.isFirstStation = NO;
    [self.lineColorView setNeedsDisplay];
    
    self.mapButton.hidden = YES;
    self.schemeButton.hidden = YES;
}

- (IBAction)showMap:(id)sender
{
    [self.delegate stationCellDidRequestMap:self];
}

- (IBAction)showScheme:(id)sender
{
    [self.delegate stationCellDidRequestScheme:self];
}

@end
