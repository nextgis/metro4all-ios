//
//  MFASelectStationViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 20/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <PureLayout/PureLayout.h>
#import <NTYCSVTable/NTYCSVTable.h>

#import "AppDelegate.h"

#import "MFAStoryboardProxy.h"
#import "MFASelectStationViewController.h"
#import "MFAStationsListViewController.h"
#import "MFAStationsListViewModel.h"

#import "MFACity.h"
#import "MFAStation.h"

#import "MFARouter.h"

@interface MFASelectStationViewController () <UITableViewDelegate, UITableViewDataSource, MFAStationListDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *stationFromButton;
@property (nonatomic, weak) IBOutlet UIButton *stationToButton;
@property (nonatomic, weak) IBOutlet UIImageView *cityLogoImageView;

@property (nonatomic, strong) MFAStation *stationFrom;
@property (nonatomic, strong) MFAStation *stationTo;

@property (nonatomic, strong) NSArray *steps;

@end

@implementation MFASelectStationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.stationFromButton.tag = 0;
    self.stationToButton.tag = 1;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
    
    self.title = @"Метро для всех";
    
    UIBarButtonItem *changeCityButton = [[UIBarButtonItem alloc] initWithTitle:@"Город"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(changeCityClick:)];
    
    self.navigationItem.rightBarButtonItem = changeCityButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCity:)
                                                 name:@"MFA_CHANGE_CITY"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateButtonTitles];
}

- (void)updateButtonTitles
{
    if (self.stationFrom) {
        [self.stationFromButton setTitle:self.stationFrom.nameString forState:UIControlStateNormal];
    }
    else {
        [self.stationFromButton setTitle:@"Старт" forState:UIControlStateNormal];
    }
    
    if (self.stationTo) {
        [self.stationToButton setTitle:self.stationTo.nameString forState:UIControlStateNormal];
    }
    else {
        [self.stationToButton setTitle:@"Финиш" forState:UIControlStateNormal];
    }
    
    self.stationFromButton.titleLabel.textColor = [UIColor blackColor];
    self.stationToButton.titleLabel.textColor = [UIColor blackColor];
}

- (IBAction)changeCityClick:(id)sender
{
    UIViewController *selectCityViewController =
        [((AppDelegate *)[UIApplication sharedApplication].delegate) setupSelectCityController];
    [self presentViewController:selectCityViewController animated:YES completion:nil];
}

- (void)changeCity:(NSNotification *)note
{
    self.stationFrom = nil;
    self.stationTo = nil;
    [self updateButtonTitles];
    
    self.steps = @[];
    [self.tableView reloadData];
    
    NSDictionary *currentCityMeta = [[NSUserDefaults standardUserDefaults] objectForKey:@"MFA_CURRENT_CITY"];
    MFACity *city = [MFACity cityWithIdentifier:currentCityMeta[@"path"]];

    self.city = city;
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.steps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.steps[indexPath.row] description];
    
    return cell;
}

- (IBAction)selectStation:(UIButton *)sender
{
    MFAStationsListViewModel *viewModel = [[MFAStationsListViewModel alloc] initWithCity:self.city];
    MFAStationsListViewController *viewController = (MFAStationsListViewController *)[MFAStoryboardProxy stationsListViewController];
    viewController.viewModel = viewModel;
    viewController.delegate = self;
    
    if (sender.tag == 0) {
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
    
    [self updateButtonTitles];
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.stationFrom && self.stationTo &&
        self.stationFrom != self.stationTo) {
        // both stations are set, calculate route
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MFACityMeta meta = self.city.metaDictionary;
            NTYCSVTable *stationsTable = [[NTYCSVTable alloc] initWithContentsOfURL:[meta.filesDirectory URLByAppendingPathComponent:@"stations_en.csv"]
                                                                    columnSeparator:@";"];
            
            NTYCSVTable *edgesTable = [[NTYCSVTable alloc] initWithContentsOfURL:[meta.filesDirectory URLByAppendingPathComponent:@"graph.csv"]
                                                                    columnSeparator:@";"];
            
            MFARouter *router = [[MFARouter alloc] initWithCity:self.city
                                                       stations:stationsTable.rows
                                                          edges:edgesTable.rows];
            
            self.steps = [router routeFromStation:self.stationFrom.stationId toStation:self.stationTo.stationId];
            [self.tableView reloadData];
        });
    }
}

@end
