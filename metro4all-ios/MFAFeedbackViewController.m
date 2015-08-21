//
//  MFAFeedbackViewController.m
//  metro4all-ios
//
//  Created by marvin on 09.08.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#import <OHAlertView/OHAlertView.h>
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "MFAFeedbackViewController.h"
#import "PhotoCollectionViewCell.h"
#import "MFAStationsListViewController.h"
#import "AppDelegate.h"
#import "MFACity.h"
#import "MFAStation.h"
#import "MFANode.h"
#import "MFAStoryboardProxy.h"
#import "Buttons.h"
#import "MFAPickPointViewController.h"

#define ACTIONSHEET_TAG_CHOOSE_CATEGORY 1
#define ACTIONSHEET_TAG_ADD_PHOTO 2

@interface MFAFeedbackViewController () <UICollectionViewDelegateFlowLayout,
                                         UICollectionViewDelegate, UINavigationControllerDelegate,
                                         UICollectionViewDataSource,
                                         UIImagePickerControllerDelegate,
                                         UIAlertViewDelegate,
                                         UIActionSheetDelegate,
                                         PhotoCellDelegate,
                                         MFAStationListDelegate,
                                         MFAPickPointDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, weak) IBOutlet UICollectionView *imagesCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButtonSide;
@property (weak, nonatomic) IBOutlet AddPhotoButton *addPhotoButton;

@property (weak, nonatomic) IBOutlet UIButton *selectStationButton;
@property (weak, nonatomic) IBOutlet UIButton *selectCategoryButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberEmailSwitch;

@property (nonatomic, strong) MFAStation *selectedStation;
@property (nonatomic, strong) NSNumber *selectedCategory;
@property (nonatomic, strong) UIImage *pointScreenshot;

@property (weak, nonatomic) IBOutlet UIButton *pickPointButton;
@property (nonatomic, readonly) NSArray *categoryTitles;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectCategorylabel;
@property (weak, nonatomic) IBOutlet UILabel *addMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *photoslabel;
@property (weak, nonatomic) IBOutlet UILabel *rememberEmailLabel;

@property (weak, nonatomic) IBOutlet UIView *tooltipView;
@property (weak, nonatomic) IBOutlet UILabel *tooltipLabel;

@end

@implementation MFAFeedbackViewController
@synthesize categoryTitles = _categoryTitles;

- (NSArray *)categoryTitles
{
    if (_categoryTitles == nil) {
        _categoryTitles = @[
                            NSLocalizedString(@"Information", nil),
                            NSLocalizedString(@"Accessibility problems", nil),
                            NSLocalizedString(@"Report mistake", nil) ];
    }
    
    return _categoryTitles;
}

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
    
    self.descriptionLabel.text = NSLocalizedString(@"Please leave us a message", nil);
    self.selectStationLabel.text = NSLocalizedString(@"Station", @"select station");
    self.selectCategorylabel.text = NSLocalizedString(@"Category", @"selectCategory");
    self.addMessageLabel.text = NSLocalizedString(@"Message", @"add text message");
    self.photoslabel.text = NSLocalizedString(@"Photos", nil);
    self.addPhotoButton.placeholderText = NSLocalizedString(@"Add photo", nil);
    
    [self.sendButton setTitle:NSLocalizedString(@"Send report", @"") forState:UIControlStateNormal];
    [self.selectStationButton setTitle:NSLocalizedString(@"Select station", nil) forState:UIControlStateNormal];
    [self.selectCategoryButton setTitle:NSLocalizedString(@"Select category", nil) forState:UIControlStateNormal];
    [self.textView setValue:NSLocalizedString(@"Your message here", @"message placeholder")
                     forKey:@"placeholder"];
    [self.textView setValue:[UIColor lightGrayColor] forKey:@"placeholderColor"];
    
    self.emailTextField.placeholder = NSLocalizedString(@"To get a reply", @"email field placeholder");
    self.rememberEmailLabel.text = NSLocalizedString(@"Remember my email", nil);
    
    self.pickPointButton.hidden = YES;
    self.selectedCategory = @1;
    
    UIView *tip = [self.tooltipView viewWithTag:999];
    tip.transform = CGAffineTransformMakeRotation(M_PI/4);
    [self.tooltipView setNeedsDisplay];
    self.tooltipView.hidden = YES;
    
    self.tooltipLabel.text = NSLocalizedString(@"You can pick a point on the station layout", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self observeKeyboard];
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"REPORT_EMAIL"];
    if (email) {
        self.emailTextField.text = email;
        self.rememberEmailSwitch.on = YES;
    }
    else {
        self.rememberEmailSwitch.on = NO;
    }
    
    [self.selectCategoryButton setTitle:self.categoryTitles[self.selectedCategory.unsignedIntegerValue - 1]
                               forState:UIControlStateNormal];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopObservingKeyboard];
}

- (IBAction)pickPointClick:(id)sender
{
    [self tapTooltip:nil];
}

- (IBAction)tapTooltip:(id)sender {    
    [UIView animateWithDuration:0.1 animations:^{
        self.tooltipView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.tooltipView removeFromSuperview];
        self.tooltipView = nil;
    }];
}

- (IBAction)selectStationClick:(id)sender
{
    MFACity *currentCity = [(AppDelegate *)([UIApplication sharedApplication].delegate) currentCity];
    MFAStationsListViewModel *vm = [[MFAStationsListViewModel alloc] initWithCity:currentCity];
    MFAStationsListViewController *vc = (MFAStationsListViewController *)[MFAStoryboardProxy stationsListViewController];
    
    vc.viewModel = vm;
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)selectCategoryClick:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];

    for (NSString *title in self.categoryTitles) {
        [sheet addButtonWithTitle:title];
    }

    sheet.tag = ACTIONSHEET_TAG_CHOOSE_CATEGORY;
    [sheet showInView:self.view];
}

- (IBAction)doneButtonClick:(id)sender {
    if (self.rememberEmailSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setObject:self.emailTextField.text
                                                  forKey:@"REPORT_EMAIL"];
    }
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://reports.metro4all.org"]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    MFACity *currentCity = [(AppDelegate *)([UIApplication sharedApplication].delegate) currentCity];
    NSString *lang = [NSLocale componentsFromLocaleIdentifier:[NSLocale currentLocale].localeIdentifier][NSLocaleLanguageCode];
    
    NSMutableDictionary *params = @{ @"time" : @(floor([[NSDate date] timeIntervalSince1970] * 1000)),
                                     @"city_name" : currentCity.path,
                                     @"package_version" : currentCity.version,
                                     @"lang_device" : lang,
                                     @"lang_data" : lang,
                                     @"text" : self.textView.text ?: @"",
                                     @"cat_id" : self.selectedCategory }.mutableCopy;
    
    NSString *email = self.emailTextField.text;
    if (email.length > 0) {
        params[@"email"] = email;
    }
    
    if (self.selectedStation) {
        params[@"id_node"] = self.selectedStation.node.nodeId;
    }
    
    if (self.pointScreenshot) {
        params[@"screenshot"] = [UIImagePNGRepresentation(self.pointScreenshot) base64EncodedStringWithOptions:0];
    }
    
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:self.photos.count];
    [self.photos enumerateObjectsUsingBlock:^(UIImage *photo, NSUInteger idx, BOOL *stop) {
        NSData *data = UIImageJPEGRepresentation(photo, 0.8);
        NSString *base64 = [data base64EncodedStringWithOptions:0];
        [photos addObject:base64];
    }];
    
    if (photos.count > 0) {
        params[@"photos"] = photos;
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading photos", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    }
    
    [manager POST:@"/reports" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if (operation.response.statusCode != 200) {
            [OHAlertView showAlertWithTitle:NSLocalizedString(@"Error", nil)
                                    message:NSLocalizedString(@"Error occured while sending the feedback", nil)
                              dismissButton:NSLocalizedString(@"OK", nil)];
        }
        else {
            [OHAlertView showAlertWithTitle:NSLocalizedString(@"Thank you!", @"feedback was sent")
                                    message:NSLocalizedString(@"Your message was sent", nil)
                              cancelButton:NSLocalizedString(@"OK", nil)
                               otherButtons:nil buttonHandler:^(OHAlertView *alert, NSInteger buttonIndex) {
                                   [self performSegueWithIdentifier:@"unwindToMain" sender:nil];
                               }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [OHAlertView showAlertWithTitle:NSLocalizedString(@"Error", nil)
                                message:NSLocalizedString(@"Error occured while sending the feedback", nil)
                          dismissButton:NSLocalizedString(@"OK", nil)];
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
    NSIndexPath *indexPath = [self.imagesCollectionView indexPathForCell:cell];
    
    [OHAlertView showAlertWithTitle:NSLocalizedString(@"Warning", @"")
                            message:NSLocalizedString(@"DeletePhoto", @"")
                       cancelButton:NSLocalizedString(@"Cancel", @"")
                           okButton:NSLocalizedString(@"Yes", @"")
                      buttonHandler:^(OHAlertView *alert, NSInteger buttonIndex) {
                          if (buttonIndex != alert.cancelButtonIndex) {
                              [self deletePhotoAtIndexPath:indexPath];
                          }
                      }];
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
        self.selectedCategory = @(buttonIndex);
        [self.selectCategoryButton setTitle:self.categoryTitles[buttonIndex - 1] forState:UIControlStateNormal];
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
    self.pickPointButton.hidden = NO;
    
    self.tooltipView.hidden = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pickPointController:(MFAPickPointViewController *)controller didFinishWithImage:(UIImage *)image
{
    self.pointScreenshot = image;
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pickPoint"]) {
        MFAPickPointViewController *dest = segue.destinationViewController;
        dest.station = self.selectedStation;
        dest.delegate = self;
    }
}

@end
