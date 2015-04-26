//
//  MFAInterchangeLineColorView.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFAInterchangeLineColorView.h"

@implementation MFAInterchangeLineColorView

- (void)drawRect:(CGRect)rect {
    [self drawInterchangeWithFrame:self.bounds
                     fromLineColor:self.fromColor toLineColor:self.toColor
                       showTopStem:YES showBottomStem:YES];
}

- (void)drawInterchangeWithFrame: (CGRect)frame
                   fromLineColor:(UIColor *)lineFromColor toLineColor:(UIColor *)lineToColor
                     showTopStem: (BOOL)showTopStem showBottomStem: (BOOL)showBottomStem;
{

    //// Color Declarations
    UIColor* backgroundColor = self.backgroundColor;
    
    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 20) / 2 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 20) * 0.50000 - 0.5) + 1, 20, 20);
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
    [backgroundColor setFill];
    [rectangle2Path fill];
    
    
    if (showTopStem)
    {
        //// Rectangle 3 Drawing
        UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 5) * 0.50000) + 0.5, CGRectGetMinY(frame), 5, floor((CGRectGetHeight(frame)) * 0.50000 + 0.5))];
        [lineFromColor setFill];
        [rectangle3Path fill];
    }
    
    
    if (showBottomStem)
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 5) * 0.50000) + 0.5, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame)) * 0.50000 + 0.5), 5, CGRectGetHeight(frame) - floor((CGRectGetHeight(frame)) * 0.50000 + 0.5))];
        [lineToColor setFill];
        [rectanglePath fill];
    }
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 24) * 0.50000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 24) * 0.50000 + 0.5), 24, 24)];
    [backgroundColor setFill];
    [oval2Path fill];
    
    
    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 17.07, CGRectGetMinY(group) + 17.07)];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 2.93, CGRectGetMinY(group) + 17.07) controlPoint1: CGPointMake(CGRectGetMinX(group) + 13.17, CGRectGetMinY(group) + 20.98) controlPoint2: CGPointMake(CGRectGetMinX(group) + 6.83, CGRectGetMinY(group) + 20.98)];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group), CGRectGetMinY(group) + 10) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.98, CGRectGetMinY(group) + 15.12) controlPoint2: CGPointMake(CGRectGetMinX(group), CGRectGetMinY(group) + 12.56)];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 20, CGRectGetMinY(group) + 10)];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 17.07, CGRectGetMinY(group) + 17.07) controlPoint1: CGPointMake(CGRectGetMinX(group) + 20, CGRectGetMinY(group) + 12.56) controlPoint2: CGPointMake(CGRectGetMinX(group) + 19.02, CGRectGetMinY(group) + 15.12)];
        [bezierPath closePath];
        [lineToColor setFill];
        [bezierPath fill];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(group) + 17.07, CGRectGetMinY(group) + 2.93)];
        [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 2.93, CGRectGetMinY(group) + 2.93) controlPoint1: CGPointMake(CGRectGetMinX(group) + 13.17, CGRectGetMinY(group) - 0.98) controlPoint2: CGPointMake(CGRectGetMinX(group) + 6.83, CGRectGetMinY(group) - 0.98)];
        [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(group), CGRectGetMinY(group) + 10) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.98, CGRectGetMinY(group) + 4.88) controlPoint2: CGPointMake(CGRectGetMinX(group), CGRectGetMinY(group) + 7.44)];
        [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(group) + 20, CGRectGetMinY(group) + 10)];
        [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 17.07, CGRectGetMinY(group) + 2.93) controlPoint1: CGPointMake(CGRectGetMinX(group) + 20, CGRectGetMinY(group) + 7.44) controlPoint2: CGPointMake(CGRectGetMinX(group) + 19.02, CGRectGetMinY(group) + 4.88)];
        [bezier2Path closePath];
        [lineFromColor setFill];
        [bezier2Path fill];
    }
}


@end
