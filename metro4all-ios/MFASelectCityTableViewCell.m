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
    [super prepareForReuse];
    
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
        
        name = name ?: self.viewModel[@"name"];
        
        NSString *subtitle = self.viewModel[@"archiveSize"];

        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[name stringByAppendingString:@" "]
                                                                                  attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
                                                                                                NSForegroundColorAttributeName : [UIColor blackColor] }];
        
        if (subtitle.length > 0) {
            NSAttributedString *details = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"(%@)", subtitle]
                                                                         attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.0f],
                                                                                       NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
            [title appendAttributedString:details];
        }
        
        self.titleLabel.attributedText = title;
    }
    else {
        self.titleLabel.text = nil;
    }
}

@end
