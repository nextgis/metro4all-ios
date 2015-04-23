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
    CGRect group = CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 12) * 0.50000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 12) * 0.50000 - 0.5) + 1, 12, 12);
    
    
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
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 20) / 2 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 20) * 0.50000 + 0.5), 20, 20)];
    [backgroundColor setFill];
    [oval2Path fill];
    
    
    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 10.24, CGRectGetMinY(group) + 10.24)];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 1.76, CGRectGetMinY(group) + 10.24) controlPoint1: CGPointMake(CGRectGetMinX(group) + 7.9, CGRectGetMinY(group) + 12.59) controlPoint2: CGPointMake(CGRectGetMinX(group) + 4.1, CGRectGetMinY(group) + 12.59)];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group), CGRectGetMinY(group) + 6) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.59, CGRectGetMinY(group) + 9.07) controlPoint2: CGPointMake(CGRectGetMinX(group), CGRectGetMinY(group) + 7.54)];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 12, CGRectGetMinY(group) + 6)];
        [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 10.24, CGRectGetMinY(group) + 10.24) controlPoint1: CGPointMake(CGRectGetMinX(group) + 12, CGRectGetMinY(group) + 7.54) controlPoint2: CGPointMake(CGRectGetMinX(group) + 11.41, CGRectGetMinY(group) + 9.07)];
        [bezierPath closePath];
        [lineToColor setFill];
        [bezierPath fill];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(group) + 10.24, CGRectGetMinY(group) + 1.76)];
        [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 1.76, CGRectGetMinY(group) + 1.76) controlPoint1: CGPointMake(CGRectGetMinX(group) + 7.9, CGRectGetMinY(group) - 0.59) controlPoint2: CGPointMake(CGRectGetMinX(group) + 4.1, CGRectGetMinY(group) - 0.59)];
        [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(group), CGRectGetMinY(group) + 6) controlPoint1: CGPointMake(CGRectGetMinX(group) + 0.59, CGRectGetMinY(group) + 2.93) controlPoint2: CGPointMake(CGRectGetMinX(group), CGRectGetMinY(group) + 4.46)];
        [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(group) + 12, CGRectGetMinY(group) + 6)];
        [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(group) + 10.24, CGRectGetMinY(group) + 1.76) controlPoint1: CGPointMake(CGRectGetMinX(group) + 12, CGRectGetMinY(group) + 4.46) controlPoint2: CGPointMake(CGRectGetMinX(group) + 11.41, CGRectGetMinY(group) + 2.93)];
        [bezier2Path closePath];
        [lineFromColor setFill];
        [bezier2Path fill];
    }
}

@end
