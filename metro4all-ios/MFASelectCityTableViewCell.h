//
//  MFASelectCityTableViewCell.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionary+CityMeta.h"

@class MFASelectCityTableViewCell;

@protocol MFASelectCityCellDelegate <NSObject>

- (void)selectCityCellDidRequestUpdate:(MFACityMeta *)meta;

@end

@interface MFASelectCityTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *viewModel;
@property (nonatomic, weak) id<MFASelectCityCellDelegate> delegate;

@end