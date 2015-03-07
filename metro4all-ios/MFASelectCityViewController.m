//
//  ViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFASelectCityViewController.h"
#import "MFASelectCityViewModel.h"
#import "MFASelectCityTableViewCell.h"

#import "MFAStationsListViewController.h"
#import "MFAStoryboardProxy.h"

@interface MFASelectCityViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@interface MFASelectCityViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *selectedRow;
@property (nonatomic, weak) UIBarButtonItem *doneButton;

@end

@implementation MFASelectCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Выберите ваш город";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(selectionDone:)];
    doneButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = doneButton;
    self.doneButton = doneButton;
}

- (void)viewWillAppear:(BOOL)animated
{
//    self.tableView.hidden = YES;
    
    [[self viewModel] loadCitiesWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
//            self.viewModel.selectedCity = self.viewModel.cities[0];
        });
    }];
}

- (IBAction)selectionDone:(id)sender
{
    NSIndexPath *selectedIndexPath = self.selectedRow;
    NSDictionary *selectedCity = self.viewModel.cities[selectedIndexPath.row];
    
    [self.viewModel processCityMeta:selectedCity withCompletion:^{
        [[NSUserDefaults standardUserDefaults] setObject:selectedCity forKey:@"MFA_CURRENT_CITY"];
        
        MFAStationsListViewController *stationsList = (MFAStationsListViewController *)[MFAStoryboardProxy stationsListViewController];
        stationsList.viewModel = [[MFAStationsListViewModel alloc] initWithCity:self.viewModel.selectedCity];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:stationsList];
        [self presentViewController:navController animated:YES completion:nil];
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
    
    if ([self.selectedRow isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedRow isEqual:indexPath] == NO) {
        
        NSArray *indexPaths = nil;
        
        if (self.selectedRow) {
            indexPaths = @[ self.selectedRow, indexPath ];
        }
        else {
            indexPaths = @[ indexPath ];
        }
        
        self.selectedRow = indexPath;
        
        // select new row
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

        self.doneButton.enabled = YES;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = nil;
    self.doneButton.enabled = NO;
    
    [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
