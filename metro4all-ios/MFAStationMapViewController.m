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
@property (nonatomic, weak) IBOutlet UIImageView *schemeView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *modeSwitch;

@end

@implementation MFAStationMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D stationPos = self.viewModel.stationPos;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(stationPos, 500, 500);
    self.mapView.region = mapRegion;
    
    [self bindViewModel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MKPlacemark *station = [[MKPlacemark alloc] initWithCoordinate:self.viewModel.stationPos
                                                 addressDictionary:nil];
    [self.mapView addAnnotation:station];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.viewModel.showsMap = YES;
    }
    else {
        self.viewModel.showsMap = NO;
    }
    
    [self bindViewModel];
}

- (void)bindViewModel
{
    self.title = self.viewModel.stationName;
    
    self.mapView.hidden = !self.viewModel.showsMap;
    
    self.schemeView.hidden = self.viewModel.showsMap;
    self.schemeView.image = self.viewModel.stationSchemeImage;
    
    self.modeSwitch.selectedSegmentIndex = self.viewModel.showsMap ? 0 : 1;
}
@end
