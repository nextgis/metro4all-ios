//
//  ViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <Reachability/Reachability.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "MFASelectCityViewController.h"
#import "MFASelectCityViewModel.h"
#import "MFASelectCityTableViewCell.h"

#import "MFAStationsListViewController.h"
#import "MFAStoryboardProxy.h"

@interface MFASelectCityViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@interface MFASelectCityViewController ()

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

- (IBAction)selectionDone:(NSIndexPath *)indexPath
{
    void(^completionBlock)() = ^() {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            MFAStationsListViewController *stationsList = (MFAStationsListViewController *)[MFAStoryboardProxy stationsListViewController];
            stationsList.viewModel = [[MFAStationsListViewModel alloc] initWithCity:self.viewModel.selectedCity];
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:stationsList];
            [self presentViewController:navController animated:YES completion:nil];
        }
    };
    
    if (indexPath.section == 1 || [self numberOfSectionsInTableView:self.tableView] == 1) {
        NSDictionary *selectedCity = self.viewModel.cities[indexPath.row];
        
        [SVProgressHUD showWithStatus:@"Загружаются данные города" maskType:SVProgressHUDMaskTypeBlack];
        
        [self.viewModel processCityMeta:selectedCity withCompletion:^{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Данные загружены" maskType:SVProgressHUDMaskTypeBlack];
            
            completionBlock();
        }
                                  error:^(NSError *error) {
                                      [SVProgressHUD dismiss];
                                      [self showErrorMessage];
                                  }];
    }
    else {
        [self.viewModel changeCity:(self.viewModel.loadedCities[indexPath.row])];
        completionBlock();
    }
}

- (void)showErrorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:@"Произошла ошибка при загрузке данных. Попробуйте повторить операцию или обратитесь в поддержку"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    });
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.viewModel titleForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFASelectCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MFA_selectCityCell"
                                                                       forIndexPath:indexPath];
    
    cell.viewModel = [self.viewModel viewModelForRow:indexPath.row inSection:indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectionDone:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (indexPath.section == 1 || [self numberOfSectionsInTableView:self.tableView] == 1) {
        // only edit loaded cities
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
        [self.tableView reloadData];
    }
}

@end
