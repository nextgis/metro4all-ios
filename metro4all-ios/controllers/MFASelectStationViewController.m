//
//  MFASelectStationViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 20/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <PureLayout/PureLayout.h>
#import <NTYCSVTable/NTYCSVTable.h>
#import <RESideMenu/RESideMenu.h>

#import "AppDelegate.h"

#import "MFAStoryboardProxy.h"
#import "MFASelectStationViewController.h"

#import "MFAStationMapViewController.h"
#import "MFAStationMapViewModel.h"

#import "MFAStationsListViewController.h"
#import "MFAStationsListViewModel.h"

#import "MFARouteTableViewStationCell.h"
#import "MFARouteTableViewInterchangeCell.h"

#import "MFACity.h"
#import "MFAStation.h"
#import "MFALine.h"

#import "MFARouter.h"

@interface MFASelectStationViewController () <UITableViewDelegate,
                                              UITableViewDataSource,
                                              MFAStationListDelegate,
                                              MFARouteTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *stationFromButton;
@property (nonatomic, weak) IBOutlet UIButton *stationToButton;
@property (nonatomic, weak) IBOutlet UIImageView *cityLogoImageView;

@property (nonatomic, strong) MFAStation *stationFrom;
@property (nonatomic, strong) MFAStation *stationTo;

@property (nonatomic, strong) NSArray *steps;

@property (nonatomic, strong) NSIndexPath *selectedRow;

@end

@implementation MFASelectStationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.stationFromButton.tag = 0;
    self.stationToButton.tag = 1;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
    
    self.title = @"Метро для всех";
    
    UIBarButtonItem *changeCityButton = [[UIBarButtonItem alloc] initWithTitle:@"Меню"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(showMenu:)];
    
    self.navigationItem.leftBarButtonItem = changeCityButton;
    
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

- (IBAction)showMenu:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id routeStep = self.steps[indexPath.row];
    NSAssert(routeStep != nil, @"route step cannot be nil");
    
    if ([routeStep isKindOfClass:[MFAStation class]]) {
        if ([indexPath isEqual:self.selectedRow]) {
            return 85.0f;
        }
        else {
            return 49.0f;
        }
    }
    else {
        if ([indexPath isEqual:self.selectedRow]) {
            return 122.0f;
        }
        else {
            return 88.0f;
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id routeStep = self.steps[indexPath.row];
    NSAssert(routeStep != nil, @"route step cannot be nil");
    
    if ([routeStep isKindOfClass:[MFAStation class]]) {
        MFARouteTableViewStationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MFA_routeStationCell"
                                                                             forIndexPath:indexPath];
        
        MFAStation *station = routeStep;
        
        cell.station = station;
        cell.lineColorView.lineColor = station.line.color;
        cell.lineColorView.isFirstStation = (indexPath.row == 0) ? YES : NO;
        cell.lineColorView.isLastStation = (indexPath.row == self.steps.count - 1) ? YES : NO;
        
        cell.stationNameLabel.text = station.nameString;
        
        if ([self.selectedRow isEqual:indexPath]) {
            cell.mapButton.hidden = NO;
            cell.schemeButton.hidden = NO;
        }
        
        cell.delegate = self;
        
        return cell;
    }
    else {
        MFARouteTableViewInterchangeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MFA_routeInterchangeCell"
                                                                                 forIndexPath:indexPath];
        
        MFAInterchange *interchange = routeStep;
        
        cell.interchange = interchange;
        
        cell.interchangeColorView.fromColor = interchange.fromStation.line.color;
        cell.interchangeColorView.toColor = interchange.toStation.line.color;
        
        cell.interchangeColorView.isFirstStep = (indexPath.row == 0) ? YES : NO;
        cell.interchangeColorView.isLastStep = (indexPath.row == self.steps.count - 1) ? YES : NO;

        cell.stationFromNameLabel.text = interchange.fromStation.nameString;
        cell.stationToNameLabel.text = interchange.toStation.nameString;
        
        if ([self.selectedRow isEqual:indexPath]) {
            cell.mapButton.hidden = NO;
            cell.schemeButton.hidden = NO;
        }
        
        cell.delegate = self;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id routeStep = self.steps[indexPath.row];
    NSAssert(routeStep != nil, @"route step cannot be nil");
    
//    [[(MFARouteTableViewStationCell *)[tableView cellForRowAtIndexPath:indexPath] lineColorView] setNeedsDisplay];
    
    [tableView beginUpdates];
    
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
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//        for (NSIndexPath *indexPath in indexPaths) {
//            [[(MFARouteTableViewStationCell *)[tableView cellForRowAtIndexPath:indexPath] lineColorView] setNeedsDisplay];
//        }   
    }
    
    [tableView endUpdates];
}

- (void)stationCellDidRequestMap:(MFARouteTableViewStationCell *)cell
{
    [self showMapForStation:cell.station];
}

- (void)stationCellDidRequestScheme:(MFARouteTableViewStationCell *)cell
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

- (IBAction)selectStation:(UIButton *)sender
{
    self.selectedRow = nil;
    
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
            MFACityMeta *meta = self.city.metaDictionary;
            NTYCSVTable *stationsTable = [[NTYCSVTable alloc] initWithContentsOfURL:[meta.filesDirectory URLByAppendingPathComponent:@"stations_en.csv"]
                                                                    columnSeparator:@";"];
            
            NTYCSVTable *edgesTable = [[NTYCSVTable alloc] initWithContentsOfURL:[meta.filesDirectory URLByAppendingPathComponent:@"graph.csv"]
                                                                    columnSeparator:@";"];
            
            MFARouter *router = [[MFARouter alloc] initWithCity:self.city
                                                       stations:stationsTable.rows
                                                          edges:edgesTable.rows];
            
            self.steps = [router routeFromStation:self.stationFrom.stationId toStation:self.stationTo.stationId];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    }
}

@end
