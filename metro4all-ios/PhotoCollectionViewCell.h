//
//  PhotoCollectionViewCell.h
//  Salon
//
//  Created by Maxim Smirnov on 23.03.15.
//  Copyright (c) 2015 aipmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoCollectionViewCell;

@protocol PhotoCellDelegate <NSObject>

- (void)photoCellHitDeleteButton:(PhotoCollectionViewCell *)cell;

@end

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<PhotoCellDelegate> delegate;
@property (nonatomic) BOOL showDeleteButton;
@property (nonatomic, strong) UIImage *image;

@end
