//
//  MFARouteTableViewStationCell.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFARouteTableViewStationCell.h"

@implementation MFARouteTableViewStationCell

- (void)prepareForReuse
{
    self.lineColorView.isLastStation = NO;
    self.lineColorView.isFirstStation = NO;
    [self.lineColorView setNeedsDisplay];
}
@end
