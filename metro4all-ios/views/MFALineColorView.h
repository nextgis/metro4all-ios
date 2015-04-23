//
//  MFALineColorView.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 23/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFALineColorView : UIView

@property (nonatomic, copy) UIColor *lineColor;
@property (nonatomic) BOOL isFirstStation;
@property (nonatomic) BOOL isLastStation;

@end
