//
//  MFASideMenuViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 28/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFASideMenuViewController.h"

@interface MFASideMenuViewController ()

@end

@implementation MFASideMenuViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate sideMenu:self didSelectItem:indexPath.row];
}

@end
