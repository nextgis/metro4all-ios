//
//  MFASelectStationViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 20/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <PureLayout/PureLayout.h>

#import "MFAStoryboardProxy.h"
#import "MFASelectStationViewController.h"
#import "MFAStationsListViewController.h"
#import "MFAStationsListViewModel.h"

#import "MFACity.h"
#import "MFAStation.h"

@interface MFASelectStationViewController () <UITableViewDelegate, UITableViewDataSource, MFAStationListDelegate>

@property (nonatomic, strong, readwrite) MFACity *city;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) MFAStation *stationFrom;
@property (nonatomic, strong) MFAStation *stationTo;

@end

@implementation MFASelectStationViewController

- (instancetype)initWithCity:(MFACity *)city
{
    self = [super init];
    if (self) {
        self.city = city;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UITableView *tableView = [[UITableView alloc] initForAutoLayout];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self.view addSubview:tableView];
    
    [tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    tableView.tableFooterView = [UIView new];
    
    self.tableView = tableView;
    
    self.title = @"Метро для всех";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        if (self.stationFrom) {
            cell.textLabel.text = self.stationFrom.nameString;
        }
        else {
            cell.textLabel.text = @"Станция отправления";
        }
    }
    else {
        if (self.stationTo) {
            cell.textLabel.text = self.stationTo.nameString;
        }
        else {
            cell.textLabel.text = @"Станция назначения";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFAStationsListViewModel *viewModel = [[MFAStationsListViewModel alloc] initWithCity:self.city];
    MFAStationsListViewController *viewController = (MFAStationsListViewController *)[MFAStoryboardProxy stationsListViewController];
    viewController.viewModel = viewModel;
    viewController.delegate = self;
    
    if (indexPath.row == 0) {
        viewController.fromStation = YES;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)stationList:(MFAStationsListViewController *)controller didSelectStation:(MFAStation *)station
{
    if (controller.fromStation) {
        self.stationFrom = station;
    }
    else {
        self.stationTo = station;
    }
    
    [self.tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
