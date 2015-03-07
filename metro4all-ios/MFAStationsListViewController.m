//
//  MFAStationsListViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFAStoryboardProxy.h"

#import "MFAStationsListViewController.h"
#import "MFAStationListTableViewCell.h"

#import "MFAStationMapViewController.h"
#import "MFAStationMapViewModel.h"

#import "MFACity.h"

@interface MFAStationsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation MFAStationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.viewModel.cityName;
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFAStationListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MFA_stationCell" forIndexPath:indexPath];
    cell.station = self.viewModel.stations[indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFAStation *station = self.viewModel.stations[indexPath.row];
    MFAStationMapViewModel *viewModel = [[MFAStationMapViewModel alloc] initWithStation:station];
    MFAStationMapViewController *stationMapController = (MFAStationMapViewController *)[MFAStoryboardProxy stationMapViewController];
    stationMapController.viewModel = viewModel;
    
    [self.navigationController pushViewController:stationMapController animated:YES];
}

@end
