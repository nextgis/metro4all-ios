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
@property (nonatomic, strong) UIImage *legendImage;
@property (nonatomic, weak) IBOutlet UIView *containerView;

@end

@implementation MFALegendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Map legend", nil);
    
    UIImage *image = nil;
    
    for (NSString *lang in [NSLocale preferredLanguages]) {
        NSString *imageName = [@"legend_" stringByAppendingString:[lang substringToIndex:2]];
        
        image = [UIImage imageNamed:imageName];
        
        if (image != nil) {
            break;
        }
    }
    
    if (image == nil) {
        image = [UIImage imageNamed:@"legend_en"];
    }
    
    self.legendImage = image;
    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                action:@selector(zoomImage:)];
//    doubleTap.numberOfTapsRequired = 2;
//    doubleTap.numberOfTouchesRequired = 1;
//    
//    [self.scrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *pinch = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(scrollViewTwoFingerTapped:)];
    pinch.numberOfTapsRequired = 1;
    pinch.numberOfTouchesRequired = 2;
    
    [self.scrollView addGestureRecognizer:pinch];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.legendImage];
    [self.scrollView addSubview:imageView];
    
    self.containerView = imageView;
    
    self.scrollView.contentSize = self.legendImage.size;
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = [self minimumZoomScale];
    
    // fit image into screen
    self.scrollView.zoomScale = [self minimumZoomScale];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self centerScrollViewContents];
}

- (CGFloat)minimumZoomScale
{
    CGRect scrollViewFrame = self.scrollView.frame;
    
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    return minScale;
}

- (void)zoomImage:(UIGestureRecognizer *)recognizer
{
    // 1
    CGPoint pointInView = [recognizer locationInView:self.scrollView.subviews[0]];
    
    // 2
    CGFloat newZoomScale = self.scrollView.zoomScale * 2.0;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.scrollView.frame.size;
    
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
    
    contentsFrame.origin.y = 0.0f;
    
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
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self centerScrollViewContents];
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
