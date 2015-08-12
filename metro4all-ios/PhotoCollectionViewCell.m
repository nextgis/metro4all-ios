//
//  PhotoCollectionViewCell.m
//  Salon
//
//  Created by Maxim Smirnov on 23.03.15.
//  Copyright (c) 2015 aipmedia. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@interface PhotoCollectionViewCell ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

@end

@implementation PhotoCollectionViewCell

- (void)awakeFromNib
{
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

- (IBAction)deleteButtonClick:(id)sender
{
    [self.delegate photoCellHitDeleteButton:self];
}

- (void)prepareForReuse
{
    self.imageView.image = nil;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.hidden = NO;
    
    if (self.showDeleteButton) {
        self.deleteButton.hidden = NO;
    }
    else {
        self.deleteButton.hidden = YES;
    }
    
    self.activityIndicator.hidden = YES;
    
    self.imageView.image = image;
}

@end
