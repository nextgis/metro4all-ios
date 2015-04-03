//
//  MFAPortalAnnotationView.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 13.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFAPortalAnnotation.h"
#import "MFAPortalAnnotationView.h"

const CGFloat annotationSize = 24.0f;

@interface MFAPortalAnnotationView ()

@property (nonatomic, strong) NSNumber *portalNumber;

@end

@implementation MFAPortalAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, annotationSize, annotationSize);
        self.backgroundColor = [UIColor clearColor];
        
        if ([annotation isKindOfClass:[MFAPortalAnnotation class]]) {
            self.portalNumber = ((MFAPortalAnnotation *)annotation).portalNumber;
            if ([(MFAPortalAnnotation *)annotation nodePortal]) {
                self.alpha = 0.75f; // 
            }
        }
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self drawPortalAnnotationWithPortalNumber:[self.portalNumber stringValue]
                                annotationSize:annotationSize];
}

- (void)drawPortalAnnotationWithPortalNumber:(NSString*)portalNumber annotationSize:(CGFloat)annotationSize;
{
    
    //// Variable Declarations
    CGFloat textSize = annotationSize * (24.0 / 40.0);
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, annotationSize, annotationSize);
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 1, CGRectGetMinY(frame) + 1, CGRectGetWidth(frame) - 2, CGRectGetHeight(frame) - 2)];
    [UIColor.darkGrayColor setFill];
    [ovalPath fill];
    [UIColor.whiteColor setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: textSize], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: textStyle};
    
    [portalNumber drawInRect: CGRectOffset(textRect, 0, (CGRectGetHeight(textRect) - [portalNumber boundingRectWithSize: textRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: textFontAttributes context: nil].size.height) / 2) withAttributes: textFontAttributes];
}

@end
