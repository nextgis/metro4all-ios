//
//  MFALineColorView.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFALineColorView.h"

IB_DESIGNABLE

@implementation MFALineColorView

- (void)drawRect:(CGRect)rect {
    [self drawLineWithFrame:self.bounds
                      color:self.lineColor
                showTopStem:!self.isFirstStation
             showBottomStem:!self.isLastStation];
}

// generated with PaintCode
- (void)drawLineWithFrame: (CGRect)frame color:(UIColor *)lineColor showTopStem: (BOOL)showTopStem showBottomStem: (BOOL)showBottomStem;
{
    //// Color Declarations
    UIColor* backgroundColor = self.backgroundColor;
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
    [backgroundColor setFill];
    [rectangle2Path fill];
    
    
    if (showTopStem)
    {
        //// Rectangle 3 Drawing
        UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 5) * 0.50000) + 0.5, CGRectGetMinY(frame), 5, floor((CGRectGetHeight(frame)) * 0.50000 + 0.5))];
        [lineColor setFill];
        [rectangle3Path fill];
    }
    
    
    if (showBottomStem)
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 5) * 0.50000) + 0.5, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame)) * 0.50000 + 0.5), 5, CGRectGetHeight(frame) - floor((CGRectGetHeight(frame)) * 0.50000 + 0.5))];
        [lineColor setFill];
        [rectanglePath fill];
    }
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 20) / 2 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 20) * 0.50000 + 0.5), 20, 20)];
    [backgroundColor setFill];
    [oval2Path fill];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 12) * 0.50000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 12) * 0.50000 + 0.5), 12, 12)];
    [lineColor setFill];
    [ovalPath fill];
}

@end
