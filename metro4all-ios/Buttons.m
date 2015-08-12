//
//  Buttons.m
//  metro4all-ios
//
//  Created by marvin on 09.08.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "Buttons.h"
#import "StyleKit.h"

@implementation BaseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end

@implementation DeletePhotoButton

- (void)drawRect:(CGRect)rect
{
    [StyleKit drawDeletePhotoButtonWithFrame:self.bounds isHighlighted:self.isHighlighted];
}

@end

@implementation AddPhotoButton

- (void)drawRect:(CGRect)rect
{
    if (self.addPhotoButtonSide) {
        [StyleKit drawAddPhotoButtonSideWithFrame:self.bounds isHighlighted:self.isHighlighted];
    }
    else {
        [StyleKit drawAddPhotoButtonWithFrame:rect isHighlighted:self.highlighted withText:_placeholderText];
    }
}

@end

