//
//  ViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <Reachability/Reachability.h>
#import <MagicalRecord/MagicalRecord.h>

#import "MFAMenuContainerViewController.h"
#import "MFASelectCityViewController.h"
#import "MFASelectCityViewModel.h"
#import "MFASelectCityTableViewCell.h"

#import "MFAStationsListViewController.h"
#import "MFASelectStationViewController.h"
#import "MFAMenuContainerViewController.h"

#import "MFAStoryboardProxy.h"

@interface MFASelectCityViewController () <UITableViewDataSource, UITableViewDelegate, MFASelectCityCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *noInternetFooterView;
@property (nonatomic, strong) Reachability *reachability;

@end

@implementation MFASelectCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Выберите ваш город";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44.0;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tableView.tableFooterView = [UIView new];
    self.reachability = [Reachability reachabilityForInternetConnection];
    
    if (self.reachability.isReachable) {
        [self loadCities];
    }
    else {
        __weak typeof(self) welf = self;
        self.reachability.reachableBlock = ^(Reachability *reachability) {
            reachability.reachableBlock = nil;
            welf.tableView.tableFooterView = [UIView new];
            [welf loadCities];
        };
        
        if (self.viewModel.loadedCities.count) {
            self.noInternetFooterView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 500);
            CGRect newFrame = self.noInternetFooterView.frame;
            
            [self.noInternetFooterView setNeedsLayout];
            [self.noInternetFooterView layoutIfNeeded];
            
            CGSize newSize = [self.noInternetFooterView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
            newFrame.size.height = newSize.height;
            self.noInternetFooterView.frame = newFrame;
            
            self.tableView.tableFooterView = self.noInternetFooterView;
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Отсутствует соединение с интернетом"
                                        message:@"Приложение «Метро для всех» требует для работы соединение с интернетом. Проверьте настройки или повторите запрос позднее"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }
}

- (void)loadCities
{
    [[[[self.viewModel.loadMetaFromServerCommand execute:nil] initially:^{
        [SVProgressHUD showWithStatus:@"Загружаю список городов"
                             maskType:SVProgressHUDMaskTypeBlack];
    }] finally:^{
        [SVProgressHUD dismiss];
    }] subscribeCompleted:^{
        [self.tableView reloadData];
    }];
}

- (void)openMainScreen
{
    if (self.sideMenuViewController) {
        // if changing city, not loading first one
        [(MFAMenuContainerViewController *)self.sideMenuViewController sideMenu:nil didSelectItem:0];
    }
    else {
        MFAMenuContainerViewController *menuVC =
        (MFAMenuContainerViewController *)[MFAStoryboardProxy menuContainerViewController];
        
        [self presentViewController:menuVC animated:YES completion:nil];
    }
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel numberOfRowsInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.viewModel.numberOfSections > 1) {
        UITableViewCell *view = [tableView dequeueReusableCellWithIdentifier:@"MFA_selectCitySectionHeader"];
        UILabel *titleLabel = (UILabel *)[view viewWithTag:999];
        titleLabel.text = [self.viewModel titleForHeaderInSection:section];
        
        return view.contentView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.viewModel.numberOfSections > 1) {
        return 44.0f;
    }

    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFASelectCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MFA_selectCityCell"
                                                                       forIndexPath:indexPath];
    
    cell.viewModel = [self.viewModel viewModelForRow:indexPath.row inSection:indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 || self.viewModel.numberOfSections == 1) {
        [self.viewModel downloadCity:self.viewModel.cities[indexPath.row] completion:^{
            [tableView reloadData];
            [self openMainScreen];
        }];
    }
    else {
        [self.viewModel changeCity:self.viewModel.loadedCities[indexPath.row]];
        [tableView reloadData];
        [self openMainScreen];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (indexPath.section == 1 || [self numberOfSectionsInTableView:self.tableView] == 1) {
        // only edit loaded cities
        return NO;
    }
    
    if ([tableView numberOfRowsInSection:indexPath.section] == 1) {
        // cannot delete last loaded city to avoid troubles
        return NO;
    }
    
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] == UITableViewCellAccessoryCheckmark) {
        return NO;
    }
    
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.viewModel deleteCityAtIndex:indexPath.row];
        
        [self.tableView setEditing:NO];
        
        [[self.viewModel.loadMetaFromServerCommand execute:nil] subscribeCompleted:^{
            [self.tableView reloadData];
        }];
    }
}

- (void)selectCityCellDidRequestUpdate:(NSDictionary *)meta
{
    [self.viewModel downloadCity:meta completion:^{
        [self openMainScreen];
    }];
}

@end
