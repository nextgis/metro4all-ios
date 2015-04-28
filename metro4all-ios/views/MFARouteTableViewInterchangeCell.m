//
//  MFARouteTableViewInterchangeCell.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFARouteTableViewInterchangeCell.h"
#import "MFAInterchange.h"

@implementation MFARouteTableViewInterchangeCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.interchangeColorView.isFirstStep = NO;
    self.interchangeColorView.isLastStep = NO;
    [self.interchangeColorView setNeedsDisplay];
}

- (MFAStation *)station
{
    return self.interchange.fromStation;
}

@end
