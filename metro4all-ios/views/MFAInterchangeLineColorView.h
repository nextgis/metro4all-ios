//
//  MFAInterchangeLineColorView.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFAInterchangeLineColorView : UIView

@property (nonatomic, strong) UIColor *fromColor;
@property (nonatomic, strong) UIColor *toColor;

@property (nonatomic) BOOL isFirstStep;
@property (nonatomic) BOOL isLastStep;

@end
