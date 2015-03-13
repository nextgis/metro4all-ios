//
//  MFAStationMapViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 04.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import <MapKit/MapKit.h>
#import <MBXRasterTileRenderer.h>

#import "MFAStationMapViewController.h"
#import "MFAPortalAnnotationView.h"

@interface MFAStationMapViewController () <UIScrollViewDelegate, MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKTileOverlay *tileOverlay;

@property (nonatomic, weak) IBOutlet UIScrollView *schemeScrollView;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIImageView *schemeOverlayView;

@property (nonatomic, weak) IBOutlet UISegmentedControl *modeSwitch;

@property (nonatomic, weak) IBOutlet UISwitch *detailsSwitch;
@property (nonatomic, weak) IBOutlet UILabel *detailsSwitchLabel;

@property (nonatomic, strong) NSArray *imageSizeConstraints;

@end

@implementation MFAStationMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RAC(self, title) = RACObserve(self.viewModel, stationName);
    
    RACSignal *showsMapSignal = RACObserve(self.viewModel, showsMap);
    
    RAC(self.mapView, hidden) = [showsMapSignal not];
    
    RAC(self.schemeScrollView, hidden) = showsMapSignal;
    
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
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(zoomImage:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    
    [self.schemeScrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *pinch = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(scrollViewTwoFingerTapped:)];
    pinch.numberOfTapsRequired = 1;
    pinch.numberOfTouchesRequired = 2;
    
    [self.schemeScrollView addGestureRecognizer:pinch];

    self.schemeScrollView.delegate = self;
    
    // use online overlay
    NSString *urlTemplate = @"http://c.tile.openstreetmap.org/{z}/{x}/{y}.png";
    
    self.tileOverlay = [[MKTileOverlay alloc] initWithURLTemplate:urlTemplate];
    self.tileOverlay.canReplaceMapContent = YES;
    
    [self.mapView addOverlay:self.tileOverlay level:MKOverlayLevelAboveLabels];
    
    self.mapView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D stationPos = self.viewModel.stationPos;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(stationPos, 500, 500);
    self.mapView.region = mapRegion;
    
    UIImage *schemeImage = self.viewModel.stationSchemeImage;
    UIImageView *schemeView = [[UIImageView alloc] initWithImage:schemeImage];
    UIImageView *overlayView = [[UIImageView alloc] initWithImage:self.viewModel.stationSchemeOverlayImage];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, schemeImage.size.width, schemeImage.size.height)];
    
    [container addSubview:schemeView];
    [container addSubview:overlayView];
    
    [self.schemeScrollView addSubview:container];
    self.schemeScrollView.contentSize = container.frame.size;

    self.schemeScrollView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    
    self.containerView = container;
    self.schemeOverlayView = overlayView;
    
    RAC(self.schemeOverlayView, hidden) = [RACObserve(self.viewModel, showsObstacles) not];
    
    // 5
    self.schemeScrollView.maximumZoomScale = 1.0f;
    [self setMinimumZoomScale];
    
    [self centerScrollViewContents];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [RACObserve(self.viewModel, pins) subscribeNext:^(NSArray *pins) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        for (NSDictionary *pin in self.viewModel.pins) {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake([pin[@"lat"] doubleValue],
                                                               [pin[@"lon"] doubleValue]);
            annotation.title = pin[@"title"];
            annotation.subtitle = pin[@"subtitle"];
            
            [self.mapView addAnnotation:annotation];
        }
    }];
}

- (void)setMinimumZoomScale
{
    CGRect scrollViewFrame = self.schemeScrollView.frame;
    
    CGFloat scaleWidth = scrollViewFrame.size.width / self.schemeScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.schemeScrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.schemeScrollView.minimumZoomScale = minScale;
    self.schemeScrollView.zoomScale = minScale;
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

- (void)zoomImage:(UIGestureRecognizer *)recognizer
{
    // 1
    CGPoint pointInView = [recognizer locationInView:self.schemeScrollView.subviews[0]];
    
    // 2
    CGFloat newZoomScale = self.schemeScrollView.zoomScale * 2.0;
    newZoomScale = MIN(newZoomScale, self.schemeScrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.schemeScrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.schemeScrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.schemeScrollView.bounds.size;
    CGRect contentsFrame = self.containerView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.containerView.frame = contentsFrame;
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.schemeScrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.schemeScrollView.minimumZoomScale);
    [self.schemeScrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.schemeScrollView.subviews[0];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setMinimumZoomScale];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    //The device has already rotated, that's why this method is being called.
    UIInterfaceOrientation toOrientation = [[UIDevice currentDevice] orientation];
    
    //fixes orientation mismatch (between UIDeviceOrientation and UIInterfaceOrientation)
    if (toOrientation == UIInterfaceOrientationLandscapeRight) toOrientation = UIInterfaceOrientationLandscapeLeft;
    else if (toOrientation == UIInterfaceOrientationLandscapeLeft) toOrientation = UIInterfaceOrientationLandscapeRight;
    
    UIInterfaceOrientation fromOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self willRotateToInterfaceOrientation:toOrientation duration:0.0];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self willAnimateRotationToInterfaceOrientation:toOrientation duration:[context transitionDuration]];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self didRotateFromInterfaceOrientation:fromOrientation];
    }];
    
}

#pragma mark - Map View Delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MBXRasterTileRenderer *renderer = [[MBXRasterTileRenderer alloc] initWithTileOverlay:overlay];
    
    return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"PortalView";
    
    MFAPortalAnnotationView *annotationView = (MFAPortalAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (annotationView == nil) {
        annotationView = [[MFAPortalAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
    }
    else {
        annotationView.annotation = annotation;
        [annotationView setNeedsDisplay];
    }
    
    return annotationView;
}

@end
