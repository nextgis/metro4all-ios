//
//  MFAStationMapViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import <MapKit/MapKit.h>
#import "MFAStationMapViewController.h"

@interface MFAStationMapViewController ()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIImageView *schemeView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *modeSwitch;

@property (nonatomic, weak) IBOutlet UISwitch *detailsSwitch;
@property (nonatomic, weak) IBOutlet UILabel *detailsSwitchLabel;

@end

@implementation MFAStationMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RAC(self, title) = RACObserve(self.viewModel, stationName);
    
    RACSignal *showsMapSignal = RACObserve(self.viewModel, showsMap);
    
    RAC(self.mapView, hidden) = [showsMapSignal not];
    
    RAC(self.schemeView, hidden) = showsMapSignal;
    RAC(self.schemeView, image) = RACObserve(self.viewModel, stationSchemeImage);
    
    RAC(self.modeSwitch, selectedSegmentIndex) =
        [RACObserve(self.viewModel, showsMap) map:^id(NSNumber *value) {
            if (value.boolValue) { return @0; }
            else { return @1; }
        }];
    
    RAC(self.detailsSwitchLabel, text) = [RACObserve(self.viewModel, showsMap) map:^NSString *(NSNumber *showsMap) {
        return showsMap.boolValue ? @"Отображать\nвыходы" : @"Отображать\nпрепятствия";
    }];
    
    RAC(self.detailsSwitch, on) =
        [RACSignal combineLatest:@[ showsMapSignal,
                                    RACObserve(self.viewModel, showsPortals),
                                    RACObserve(self.viewModel, showsObstacles) ]
                          reduce:^NSNumber *(NSNumber *showsMap, NSNumber *showsPortals, NSNumber *showsObstacles) {
                              return showsMap.boolValue ? showsPortals : showsObstacles;
                          }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D stationPos = self.viewModel.stationPos;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(stationPos, 500, 500);
    self.mapView.region = mapRegion;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [RACObserve(self.viewModel, pins) subscribeNext:^(NSArray *pins) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        for (NSDictionary *pin in self.viewModel.pins) {
            MKPlacemark *mark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([pin[@"lat"] doubleValue],
                                                                                                   [pin[@"lon"] doubleValue])
                                                      addressDictionary:nil];
            [self.mapView addAnnotation:mark];
        }
    }];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.viewModel.showsMap = YES;
    }
    else {
        self.viewModel.showsMap = NO;
    }
}

- (IBAction)detailsSwitchChanged:(UISwitch *)sender
{
    if (self.viewModel.showsMap) {
        self.viewModel.showsPortals = sender.isOn;
    }
    else {
        self.viewModel.showsObstacles = sender.isOn;
    }
}

@end
