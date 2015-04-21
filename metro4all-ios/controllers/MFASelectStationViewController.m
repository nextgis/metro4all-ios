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

@property (nonatomic, strong, readwrite) MFACity *city;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *stationFromButton;
@property (nonatomic, weak) IBOutlet UIButton *stationToButton;

@property (nonatomic, strong) MFAStation *stationFrom;
@property (nonatomic, strong) MFAStation *stationTo;

@property (nonatomic, strong) NSArray *steps;

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

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIView *containerView = [[UIView alloc] initForAutoLayout];
    [containerView autoSetDimension:ALDimensionHeight toSize:44.0];
    containerView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:containerView];
    
    [containerView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [containerView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [containerView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    
    UIButton *stationFromButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButton *stationToButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    stationToButton.translatesAutoresizingMaskIntoConstraints = NO;
    stationFromButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    stationFromButton.tag = 0;
    stationToButton.tag = 1;
    
    [stationFromButton addTarget:self action:@selector(selectStation:) forControlEvents:UIControlEventTouchUpInside];
    [stationToButton addTarget:self action:@selector(selectStation:) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:stationFromButton];
    [containerView addSubview:stationToButton];
    
    [stationFromButton autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [stationFromButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [stationFromButton autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [stationToButton autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [stationToButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [stationToButton autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [stationFromButton autoConstrainAttribute:ALAttributeWidth toAttribute:ALAttributeWidth ofView:stationToButton];
    
    self.stationToButton = stationToButton;
    self.stationFromButton = stationFromButton;
    
    UITableView *tableView = [[UITableView alloc] initForAutoLayout];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:tableView];
    
    [tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [tableView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    
    [tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:containerView];
    
    self.tableView = tableView;
    
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
        [self.stationFromButton setTitle:@"Станция отправления" forState:UIControlStateNormal];
    }
    
    if (self.stationTo) {
        [self.stationToButton setTitle:self.stationTo.nameString forState:UIControlStateNormal];
    }
    else {
        [self.stationToButton setTitle:@"Станция назначения" forState:UIControlStateNormal];
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

- (void)selectStation:(UIButton *)sender
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
    
    if (self.stationFrom && self.stationTo) {
        // both stations are set, calculate route
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MFACityMeta meta = self.city.metaDictionary;
            NTYCSVTable *stationsTable = [[NTYCSVTable alloc] initWithContentsOfURL:[meta.filesDirectory URLByAppendingPathComponent:@"stations_en.csv"]
                                                                    columnSeparator:@";"];
            
            NTYCSVTable *edgesTable = [[NTYCSVTable alloc] initWithContentsOfURL:[meta.filesDirectory URLByAppendingPathComponent:@"graph.csv"]
                                                                    columnSeparator:@";"];
            MFARouter *router = [[MFARouter alloc] initWithStations:stationsTable.rows edges:edgesTable.rows];
            
            self.steps = [router routeFromStation:self.stationFrom.stationId toStation:self.stationTo.stationId];
            [self.tableView reloadData];
        });
    }
}

@end
