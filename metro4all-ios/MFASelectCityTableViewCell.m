//
//  MFASelectCityTableViewCell.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFASelectCityTableViewCell.h"

@interface MFASelectCityTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation MFASelectCityTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    self.viewModel = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setViewModel:(NSDictionary *)viewModel
{
    _viewModel = viewModel;
    
    if (viewModel) {
        NSString *name = nil;
        for (NSString *lang in [NSLocale preferredLanguages]) {
            name = self.viewModel[[@"name_" stringByAppendingString:lang]];
            
            if (name != nil) {
                self.titleLabel.text = name;
                break;
            }
        }
        
        if (name == nil) {
            self.titleLabel.text = self.viewModel[@"name"];
        }
    }
    else {
        self.titleLabel.text = nil;
    }
}

@end
