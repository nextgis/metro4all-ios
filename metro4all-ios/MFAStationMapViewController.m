//
//  MFAStationMapViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MFAStationMapViewController.h"

@interface MFAStationMapViewController ()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation MFAStationMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.viewModel.stationName;
    
    CLLocationCoordinate2D stationPos = self.viewModel.stationPos;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(stationPos, 500, 500);
    self.mapView.region = mapRegion;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MKPlacemark *station = [[MKPlacemark alloc] initWithCoordinate:self.viewModel.stationPos
                                                 addressDictionary:nil];
    [self.mapView addAnnotation:station];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
