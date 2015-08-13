//
//  MFAPickPointViewController.m
//  metro4all-ios
//
//  Created by marvin on 13.08.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <PureLayout/PureLayout.h>

#import "MFAPickPointViewController.h"
#import "MFACity.h"
#import "MFANode.h"

@interface MFAPickPointViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *schemeScrollView;
@property (nonatomic, weak) UIImageView *schemeOverlayView;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, readonly) UIImage *stationSchemeImage;
@property (nonatomic, readonly) UIImage *stationSchemeOverlayImage;

@end

@implementation MFAPickPointViewController
@synthesize stationSchemeImage = _stationSchemeImage;
@synthesize stationSchemeOverlayImage = _stationSchemeOverlayImage;

- (UIImage *)stationSchemeImage
{
    if (!_stationSchemeImage) {
        MFACity *city = self.station.city;
        
        NSURL *dataURL = [city.dataDirectory.absoluteURL copy];
        NSURL *schemeURL = [NSURL URLWithString:[NSString stringWithFormat:@"schemes/%ld.png", (long)self.station.node.nodeId.integerValue]
                                  relativeToURL:dataURL];
        NSString *schemeFilePath = [schemeURL path];
        
        _stationSchemeImage = [UIImage imageWithContentsOfFile:schemeFilePath];
    }
    
    return _stationSchemeImage;
}

- (UIImage *)stationSchemeOverlayImage
{
    if (!_stationSchemeOverlayImage) {
        MFACity *city = self.station.city;
        
        NSURL *dataURL = [city.dataDirectory.absoluteURL copy];
        NSURL *schemeURL = [NSURL URLWithString:[NSString stringWithFormat:@"schemes/numbers/%ld.png", (long)self.station.node.nodeId.integerValue]
                                  relativeToURL:dataURL];
        NSString *schemeFilePath = [schemeURL path];
        
        _stationSchemeOverlayImage = [UIImage imageWithContentsOfFile:schemeFilePath];
    }
    
    return _stationSchemeOverlayImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
}

- (void)dealloc
{
    self.schemeScrollView.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = self.station.nameString;
    
    if (self.containerView == nil) {
        UIImage *schemeImage = self.stationSchemeImage;
        UIImageView *schemeView = [[UIImageView alloc] initWithImage:schemeImage];
        UIImageView *overlayView = [[UIImageView alloc] initWithImage:self.stationSchemeOverlayImage];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, schemeImage.size.width, schemeImage.size.height)];
        
        [container addSubview:schemeView];
        [container addSubview:overlayView];
        
//        [container autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
//        [schemeView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
//        [overlayView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        [self.schemeScrollView addSubview:container];
        self.schemeScrollView.contentSize = container.frame.size;
        
        self.containerView = container;
        self.schemeOverlayView = overlayView;
        
        self.schemeScrollView.maximumZoomScale = 1.0f;
    }
}

- (void)viewDidLayoutSubviews
{
    [self setMinimumZoomScale];
    [self centerScrollViewContents];
}

- (void)setMinimumZoomScale
{
    self.schemeScrollView.zoomScale = 1;
    
    CGRect scrollViewFrame = self.schemeScrollView.frame;
    
    CGFloat scaleWidth = scrollViewFrame.size.width / self.schemeScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.schemeScrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.schemeScrollView.minimumZoomScale = minScale;
    self.schemeScrollView.zoomScale = minScale;
}

- (void)zoomImage:(UIGestureRecognizer *)recognizer
{
    // 1
    CGPoint pointInView = [recognizer locationInView:self.schemeScrollView.subviews[0]];
    
    // 2
    CGFloat newZoomScale = self.schemeScrollView.zoomScale * 2.0;
    newZoomScale = MIN(newZoomScale, self.schemeScrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.schemeScrollView.frame.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.schemeScrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.schemeScrollView.frame.size;
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
    //reset zoomScale back to 1 so that contentSize can be modified correctly
    self.schemeScrollView.zoomScale = 1;
    
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
@end
