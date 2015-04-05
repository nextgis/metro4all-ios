//
//  ViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <Reachability/Reachability.h>

#import "MFASelectCityViewController.h"
#import "MFASelectCityViewModel.h"
#import "MFASelectCityTableViewCell.h"

#import "MFAStationsListViewController.h"
#import "MFAStoryboardProxy.h"

@interface MFASelectCityViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@interface MFASelectCityViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation MFASelectCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Выберите ваш город";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([Reachability reachabilityForInternetConnection]) {
        [[[[self.viewModel.loadMetaFromServerCommand execute:nil] initially:^{
            [SVProgressHUD showWithStatus:@"Загружаю список городов" maskType:SVProgressHUDMaskTypeBlack];
        }] finally:^{
            [SVProgressHUD dismiss];
        }] subscribeCompleted:^{
            [self.tableView reloadData];
        }];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Отсутствует соединение с интернетом"
                                    message:@"Приложение «Метро для всех» требует для работы соединение с интернетом. Проверьте настройки или повторите запрос позднее"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
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
    MFASelectCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MFA_selectCityCell" forIndexPath:indexPath];
    cell.viewModel = [self.viewModel viewModelForRow:indexPath.row inSection:indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectionDone:indexPath];
}

@end
