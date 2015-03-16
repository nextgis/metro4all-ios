//
//  MFALegendViewController.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 16.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFALegendViewController.h"

@interface MFALegendViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *containerView;

@end

@implementation MFALegendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Условные обозначения";
    
    UIImage *image = nil;
    
    for (NSString *lang in [NSLocale preferredLanguages]) {
        NSString *imageName = [@"legend_" stringByAppendingString:lang];
        
        image = [UIImage imageNamed:imageName];
        
        if (image != nil) {
            break;
        }
    }
    
    if (image == nil) {
        image = [UIImage imageNamed:@"legend_ru"];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView = imageView;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(zoomImage:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    
    [self.scrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *pinch = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(scrollViewTwoFingerTapped:)];
    pinch.numberOfTapsRequired = 1;
    pinch.numberOfTouchesRequired = 2;
    
    [self.scrollView addGestureRecognizer:pinch];
    
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.containerView == nil) {
        UIImage *image = self.imageView.image;
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        
        [container addSubview:self.imageView];
        
        [self.scrollView addSubview:container];
        self.scrollView.contentSize = container.frame.size;
        
        self.containerView = container;
        
        // 5
        self.scrollView.maximumZoomScale = 1.0f;
        [self setMinimumZoomScale];
        [self centerScrollViewContents];
    }    
}

- (void)setMinimumZoomScale
{
    CGRect scrollViewFrame = self.scrollView.frame;
    
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
}

- (void)zoomImage:(UIGestureRecognizer *)recognizer
{
    // 1
    CGPoint pointInView = [recognizer locationInView:self.scrollView.subviews[0]];
    
    // 2
    CGFloat newZoomScale = self.scrollView.zoomScale * 2.0;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
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
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.scrollView.subviews[0];
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

@end
