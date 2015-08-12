//
//  Buttons.h
//  metro4all-ios
//
//  Created by marvin on 09.08.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseButton : UIButton
@end


@interface DeletePhotoButton : BaseButton
@end

@interface AddPhotoButton : BaseButton
@property (nonatomic) IBInspectable NSString *placeholderText;
@property (nonatomic) BOOL addPhotoButtonSide;
@end