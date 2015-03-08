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

@interface MFAStationsListViewController () <UITableViewDataSource,
                                             UITableViewDelegate,
                                             MFAStationListTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.selectedIndexPath]) {
        return 104.0;
    }
    else {
        return 70.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFAStationListTableViewCell *cell = nil;
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MFA_selectedStationCell" forIndexPath:indexPath];
        ((MFAStationListSelectedTableViewCell *)cell).delegate = self;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MFA_stationCell" forIndexPath:indexPath];
    }
    
    cell.station = self.viewModel.stations[indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedIndexPath isEqual:indexPath] == NO) {
        
        NSArray *indexPaths = nil;
        
        if (self.selectedIndexPath) {
            indexPaths = @[ self.selectedIndexPath, indexPath ];
        }
        else {
            indexPaths = @[ indexPath ];
        }
        
        self.selectedIndexPath = indexPath;
        
        // select new row
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = nil;
    
    [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Station List Cell Delegate

- (void)stationCellDidRequestMap:(MFAStationListTableViewCell *)cell
{
    [self showMapForStation:cell.station];
}

- (void)stationCellDidRequestScheme:(MFAStationListTableViewCell *)cell
{
    [self showSchemeForStation:cell.station];
}

- (void)showSchemeForStation:(MFAStation *)station
{
    MFAStationMapViewModel *viewModel = [[MFAStationMapViewModel alloc] initWithStation:station];
    MFAStationMapViewController *stationMapController = (MFAStationMapViewController *)[MFAStoryboardProxy stationMapViewController];
    
    viewModel.showsMap = NO;
    stationMapController.viewModel = viewModel;
    
    [self.navigationController pushViewController:stationMapController animated:YES];
}

- (void)showMapForStation:(MFAStation *)station
{
    MFAStationMapViewModel *viewModel = [[MFAStationMapViewModel alloc] initWithStation:station];
    MFAStationMapViewController *stationMapController = (MFAStationMapViewController *)[MFAStoryboardProxy stationMapViewController];
    stationMapController.viewModel = viewModel;
    
    [self.navigationController pushViewController:stationMapController animated:YES];
}

@end
