//
//  MFAFeedbackViewController.m
//  metro4all-ios
//
//  Created by marvin on 09.08.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <objc/runtime.h>
#import <OHAlertView/OHAlertView.h>

#import "MFAFeedbackViewController.h"
#import "PhotoCollectionViewCell.h"
#import "MFAStationsListViewController.h"
#import "AppDelegate.h"
#import "MFAStation.h"
#import "MFAStoryboardProxy.h"

#define ACTIONSHEET_TAG_CHOOSE_CATEGORY 1
#define ACTIONSHEET_TAG_ADD_PHOTO 2

@interface MFAFeedbackViewController () <UICollectionViewDelegateFlowLayout,
                                         UICollectionViewDelegate, UINavigationControllerDelegate,
                                         UICollectionViewDataSource,
                                         UIImagePickerControllerDelegate,
                                         UIAlertViewDelegate,
                                         UIActionSheetDelegate,
                                         PhotoCellDelegate,
                                         MFAStationListDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, weak) IBOutlet UICollectionView *imagesCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButtonSide;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;

@property (weak, nonatomic) IBOutlet UIButton *selectStationButton;
@property (weak, nonatomic) IBOutlet UIButton *selectCategoryButton;

@property (nonatomic, strong) MFAStation *selectedStation;
@property (nonatomic, copy) NSString *selectedCategory;

@end

@implementation MFAFeedbackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.title = NSLocalizedString(@"Send Feedback", @"feedback screen title");
    
    self.imagesCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.imagesCollectionView.showsHorizontalScrollIndicator = NO;
    self.imagesCollectionView.showsVerticalScrollIndicator = NO;
    self.imagesCollectionView.backgroundColor = [UIColor clearColor];
    self.imagesCollectionView.delegate = self;
    self.imagesCollectionView.dataSource = self;
    self.imagesCollectionView.alwaysBounceHorizontal = YES;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 15.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 15.0, 0, 15.0);
    layout.itemSize = CGSizeMake(155.0, 155.0);
    
    self.imagesCollectionView.collectionViewLayout = layout;
    
    self.photos = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self observeKeyboard];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopObservingKeyboard];
}

- (IBAction)selectStationClick:(id)sender
{
    MFACity *currentCity = [(AppDelegate *)([UIApplication sharedApplication].delegate) currentCity];
    MFAStationsListViewModel *vm = [[MFAStationsListViewModel alloc] initWithCity:currentCity];
    MFAStationsListViewController *vc = (MFAStationsListViewController *)[MFAStoryboardProxy selectStationViewController];
    
    vc.viewModel = vm;
    vc.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)selectCategoryClick:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Information", nil),
                                                                NSLocalizedString(@"Accessibility problems", nil),
                                                                NSLocalizedString(@"Report mistake", nil), nil];
    sheet.tag = ACTIONSHEET_TAG_CHOOSE_CATEGORY;
    [sheet showInView:self.view];
}

- (IBAction)doneButtonClick:(id)sender {
    [self uploadPhotosWithSuccess:^(NSArray *photoIDs) {
        
    } error:^(NSError *error) {
        NSLog(@"Failed to upload photos: %@", error.localizedDescription);
    }];
}

- (IBAction)addPhotoButtonHandler:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Take photo", nil),
                                                                NSLocalizedString(@"Choose from library", nil), nil];
    sheet.tag = ACTIONSHEET_TAG_ADD_PHOTO;
    [sheet showInView:self.view];
}

#pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self addImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Collection View Data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.showDeleteButton = YES;
    [cell setImage:self.photos[indexPath.item]];
    
    return cell;
}

- (void)photoCellHitDeleteButton:(PhotoCollectionViewCell *)cell
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"")
                                                    message:NSLocalizedString(@"DeletePhoto", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                          otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    
    NSIndexPath *indexPath = [self.imagesCollectionView indexPathForCell:cell];
    objc_setAssociatedObject(alert, @"photoIndexPathToDelete", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [alert show];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        
        NSIndexPath *indexPath = objc_getAssociatedObject(alertView, @"photoIndexPathToDelete");
        objc_setAssociatedObject(alertView, @"photoIndexPathToDelete", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (indexPath) {
            [self deletePhotoAtIndexPath:indexPath];
        }
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (actionSheet.tag == ACTIONSHEET_TAG_ADD_PHOTO) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        switch (buttonIndex) {
                // take a picture
            case 0:
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
                
                // pick from gallery
            case 1:
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
        }
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if (actionSheet.tag == ACTIONSHEET_TAG_CHOOSE_CATEGORY) {
        self.selectedCategory = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.selectCategoryButton setTitle:self.selectedCategory forState:UIControlStateNormal];
    }
}

#pragma mark - Flow Layout Delegate

- (void)deletePhotoAtIndexPath:(NSIndexPath *)indexPath
{
    [self.photos removeObjectAtIndex:indexPath.item];
    [self.imagesCollectionView deleteItemsAtIndexPaths:@[ indexPath ]];
    
    if ([self.imagesCollectionView numberOfItemsInSection:0] == 0) {
        [self createPhotosContent];
    }
}

- (void)createPhotosContent
{
    [self.imagesCollectionView reloadData];
    
    if ([self.imagesCollectionView numberOfItemsInSection:0] == 0) {
        self.addPhotoButtonSide.hidden = YES;
        self.addPhotoButton.hidden = NO;
    }
    else {
        self.addPhotoButton.hidden = YES;
        self.addPhotoButtonSide.hidden = NO;
    }
}

- (void)addImage:(UIImage *)image
{
    [self.photos insertObject:image atIndex:0];
    [self createPhotosContent];
}

#pragma mark - Station list delegate

- (void)stationList:(MFAStationsListViewController *)controller didSelectStation:(MFAStation *)station
{
    [self.selectStationButton setTitle:station.nameString forState:UIControlStateNormal];
    self.selectedStation = station;

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadPhotosWithSuccess:(void (^)(NSArray *photoIDs))successBlock
                          error:(void (^)(NSError *error))errorBlock
{
//    [[RequestManager sharedManager] uploadPhotos:self.addedPhotos
//                                         success:successBlock
//                                           error:errorBlock];
}

#pragma mark - Keyboard avoiding

- (void)observeKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    NSLog(@"%@ is now observing keyboard events", self);
}

- (void)stopObservingKeyboard
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    NSLog(@"%@ stopped observing keyboard state", self);
}

- (void)keyboardWillShow:(NSNotification *)note
{
    NSLog(@"Need to adjust keyboard position in view controller %@", self);
    
    NSDictionary *info = [note userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    [self keyboardWillShow:height withAnimationDuration:animationDuration animationCurve:animationCurve];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    NSLog(@"Keyboard will hide in view controller %@", self);
    
    NSDictionary *info = [note userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [self keyboardWillHideWithAnimationDuration:animationDuration animationCurve:animationCurve];
}

- (void)keyboardWillShow:(CGFloat)height withAnimationDuration:(NSTimeInterval)duration animationCurve:(NSInteger)animationCurve
{
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 7)
                     animations:^{
                         self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
                     }
                     completion:nil];
}

- (void)keyboardWillHideWithAnimationDuration:(NSTimeInterval)duration animationCurve:(NSInteger)animationCurve
{
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 7)
                     animations:^{
                         self.scrollView.contentInset = UIEdgeInsetsZero;
                     }
                     completion:nil];
}


@end
