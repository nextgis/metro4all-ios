//
//  MFAStationsListViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFAStationsListViewController.h"
#import "MFAStationListTableViewCell.h"
#import "MFACity.h"

@interface MFAStationsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation MFAStationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
