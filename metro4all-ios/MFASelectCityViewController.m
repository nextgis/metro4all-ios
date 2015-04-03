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
//    self.tableView.hidden = YES;
    
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

- (IBAction)selectionDone:(NSUInteger)index
{
    NSDictionary *selectedCity = self.viewModel.cities[index];
    
    [self.viewModel processCityMeta:selectedCity withCompletion:^{
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            MFAStationsListViewController *stationsList = (MFAStationsListViewController *)[MFAStoryboardProxy stationsListViewController];
            stationsList.viewModel = [[MFAStationsListViewModel alloc] initWithCity:self.viewModel.selectedCity];
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:stationsList];
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
                              error:^(NSError *error) {
                                  [self showErrorMessage];
                              }];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFASelectCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MFA_selectCityCell" forIndexPath:indexPath];
    cell.viewModel = self.viewModel.cities[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectionDone:indexPath.item];
}

@end
