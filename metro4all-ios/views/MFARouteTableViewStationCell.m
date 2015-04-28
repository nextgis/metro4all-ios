//
//  MFARouteTableViewStationCell.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFARouteTableViewStationCell.h"

@implementation MFARouteTableViewCell

- (void)awakeFromNib
{
    self.mapButton.hidden = YES;
    self.schemeButton.hidden = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
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

@implementation MFARouteTableViewStationCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.lineColorView.isLastStation = NO;
    self.lineColorView.isFirstStation = NO;
    [self.lineColorView setNeedsDisplay];
}

@end
