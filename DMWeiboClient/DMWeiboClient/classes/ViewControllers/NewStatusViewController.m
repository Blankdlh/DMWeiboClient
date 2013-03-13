//
//  NewStatusViewController.m
//  DMWeiboClient
//
//  Created by Blank on 13-1-15.
//  Copyright (c) 2013年 戴 立慧. All rights reserved.
//

#import "NewStatusViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "SelectedImageViewController.h"
#import "EmotionSelectView.h"
#import "MyLocationViewController.h"

#define WORDSLIMIT 140

@interface NewStatusViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextViewDelegate, SelectedImageViewControllerDelegate, EmotionSelectViewDelegate, MyLocationViewControllerDelegate, UIAlertViewDelegate>
{
    BOOL isSelectingEmotion;
    BOOL hasLocation;
    CLLocationCoordinate2D _coordinate;
}
@property (nonatomic, strong)UIImagePickerController *imagePickerController;
@property (nonatomic, strong)UIImage *selectedImage;
@property (weak, nonatomic) IBOutlet UILabel *wordLimitLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSend;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) NSString *address;


@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseImage;
@property (weak, nonatomic) IBOutlet UIButton *btnTrend;
@property (weak, nonatomic) IBOutlet UIButton *btnMention;
@property (weak, nonatomic) IBOutlet UIButton *btnEmothion;

@property (nonatomic, strong) EmotionSelectView *emotionView;

@end

@implementation NewStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	// Do any additional setup after loading the view.
    isSelectingEmotion = NO;
    hasLocation = NO;
    
    self.wordLimitLabel.text = [NSString stringWithFormat:@"%d",WORDSLIMIT];
    self.imageView.layer.cornerRadius = 5;
    [self.textView becomeFirstResponder];
    self.btnSend.enabled = NO;
    
    self.btnLocation.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.btnChooseImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.btnMention.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.btnEmothion.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.btnTrend.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setWordLimitLabel:nil];
    [self setTextView:nil];
    [self setImageView:nil];
    [self setBtnSend:nil];
    [self setBtnLocation:nil];
    [self setBtnChooseImage:nil];
    [self setBtnTrend:nil];
    [self setBtnMention:nil];
    [self setBtnEmothion:nil];
    [self setLocationLabel:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WatchImage"]) {
        SelectedImageViewController *viewcontroller = segue.destinationViewController;
        viewcontroller.image = self.selectedImage;
        viewcontroller.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"Location"])
    {
        MyLocationViewController *locationController = segue.destinationViewController;
        locationController.delegate = self;
    }
}


- (EmotionSelectView*)emotionView
{
    if (_emotionView == nil) {
        _emotionView = [[EmotionSelectView alloc] initWithFrame:(CGRect){0,self.view.frame.size.height - 216,CGSizeZero}];
        _emotionView.delegate = self;
    }
    return _emotionView;
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    if (selectedImage == nil) {

        CGFloat offset = self.btnLocation.frame.origin.y;
        CGFloat btnWidth = self.view.frame.size.width / 5 ;
        CGFloat btnHeight = self.btnEmothion.frame.size.height;
        self.imageView.frame = (CGRect){btnWidth * 10, offset-2, self.imageView.frame.size};
        [UIView animateWithDuration:.5f animations:^(){
            self.btnLocation.frame = (CGRect){0, offset, btnWidth,btnHeight};
            self.btnChooseImage.frame = (CGRect){btnWidth * 1, offset, btnWidth,btnHeight};
            self.btnTrend.frame = (CGRect){btnWidth * 2, offset, btnWidth,btnHeight};
            self.btnMention.frame = (CGRect){btnWidth * 3, offset, btnWidth,btnHeight};
            self.btnEmothion.frame = (CGRect){btnWidth * 4, offset, btnWidth,btnHeight};
            
        }];

    }
    else
    {
        if (_selectedImage == nil) {
            
            CGFloat offset = self.btnLocation.frame.origin.y;
            CGFloat btnWidth = self.view.frame.size.width / 6;
            CGFloat btnHeight = self.btnEmothion.frame.size.height;
            self.imageView.frame = (CGRect){btnWidth * 5 + (btnWidth - self.imageView.frame.size.width)/2, offset-2, self.imageView.frame.size};
            [UIView animateWithDuration:.5f animations:^(){
                self.btnLocation.frame = (CGRect){0, offset, btnWidth,btnHeight};
                self.btnChooseImage.frame = (CGRect){btnWidth * 1, offset, btnWidth,btnHeight};
                self.btnTrend.frame = (CGRect){btnWidth * 2, offset, btnWidth,btnHeight};
                self.btnMention.frame = (CGRect){btnWidth * 3, offset, btnWidth,btnHeight};
                self.btnEmothion.frame = (CGRect){btnWidth * 4, offset, btnWidth,btnHeight};
                
            }];
        }
        [self.imageView setImage:selectedImage forState:UIControlStateNormal] ;
        self.btnSend.enabled = YES;
    }
    _selectedImage = selectedImage;
    
}


- (SinaWeibo *)sinaweibo
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.sinaweibo;
}

- (UIImagePickerController*)imagePickerController
{
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    
    CGFloat offset = self.view.frame.size.height - kbSize.height - self.btnLocation.frame.size.height - 10;
    [self adjustToolbarHeight:offset];
    
    if (!isSelectingEmotion) {
        [self.btnEmothion setImage:[UIImage imageNamed:@"compose_emoticonbutton_background"]  forState:UIControlStateNormal];
        [self.emotionView removeFromSuperview];
        self.btnEmothion.alpha = 0;
        [UIView animateWithDuration:.5f animations:^(){
            self.btnEmothion.alpha = 1;
        }];
        isSelectingEmotion = YES;
        
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    CGFloat offset = self.view.frame.size.height - 216 - self.btnLocation.frame.size.height - 10;
    [self adjustToolbarHeight:offset];
    
}

- (void)adjustToolbarHeight:(CGFloat)offset
{
    self.btnLocation.frame = (CGRect){self.btnLocation.frame.origin.x, offset, self.btnLocation.frame.size};
    self.btnChooseImage.frame = (CGRect){self.btnChooseImage.frame.origin.x, offset, self.btnChooseImage.frame.size};
    self.btnTrend.frame = (CGRect){self.btnTrend.frame.origin.x, offset, self.btnTrend.frame.size};
    self.btnMention.frame = (CGRect){self.btnMention.frame.origin.x, offset, self.btnMention.frame.size};
    self.btnEmothion.frame = (CGRect){self.btnEmothion.frame.origin.x, offset, self.btnEmothion.frame.size};
    self.imageView.frame = (CGRect){self.imageView.frame.origin.x, offset-2, self.imageView.frame.size};
    self.wordLimitLabel.frame = (CGRect){self.wordLimitLabel.frame.origin.x, offset - self.wordLimitLabel.frame.size.height -2, self.wordLimitLabel.frame.size};
    self.locationLabel.frame = (CGRect){self.locationLabel.frame.origin.x, offset - self.locationLabel.frame.size.height -2, self.locationLabel.frame.size};
    self.textView.frame = (CGRect){self.textView.frame.origin, self.textView.frame.size.width, self.wordLimitLabel.frame.origin.y - 2 - NAV_HEIGHT};
}


#pragma mark - Actions
- (IBAction)btnChooseLocation:(id)sender {
    if (hasLocation) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"删除位置信息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else
    {
        [self performSegueWithIdentifier:@"Location" sender:self];
    }
}

- (IBAction)btnEmotion:(id)sender {
    
    self.btnEmothion.alpha = 0;
    if (isSelectingEmotion) {
        [self.btnEmothion setImage:[UIImage imageNamed:@"compose_keyboardbutton_background"] forState:UIControlStateNormal];
        [self.textView resignFirstResponder];
        [self.view addSubview:self.emotionView];
        CGRect emotionRect = self.emotionView.frame;
        self.emotionView.frame = (CGRect){0, self.view.frame.size.height, self.emotionView.frame.size};
        [UIView animateWithDuration:.3f animations:^(){
            self.emotionView.frame = emotionRect;
        }];
        isSelectingEmotion = NO;
    }
    else
    {
        [self.textView becomeFirstResponder];
        
    }
    [UIView animateWithDuration:.5f animations:^(){
        self.btnEmothion.alpha = 1;
    }];
    
}

- (IBAction)btnChooseImage:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"用户相册", nil];
        [actionSheet showInView:self.view];
    }
    else
    {
        [self actionSheet:nil clickedButtonAtIndex:1];
    }
    
}
- (IBAction)btnSend:(id)sender {
    if (self.textView.text.length > WORDSLIMIT) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"不允许发送消息" message:@"消息文字不可以超过140个字。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alertview show];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(newStatusViewController:dismissWithStatusInfo:)]) {
            NSMutableDictionary *userinfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.textView.text, @"status",self.selectedImage, @"pic", nil];
            if (self.textView.text == nil || self.textView.text.length == 0) {
                [userinfo setValue:@"分享图片" forKey:@"status"];
            }
            if (hasLocation) {
                [userinfo setValue:[NSString stringWithFormat:@"%f",_coordinate.latitude] forKey:@"lat"];
                [userinfo setValue:[NSString stringWithFormat:@"%f",_coordinate.longitude] forKey:@"long"];
            }
            [self.delegate newStatusViewController:self dismissWithStatusInfo:userinfo];
        }
        
    }
}
- (IBAction)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://拍照
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1://相册
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            break;
        default:
            return;
            break;
    }
    [self presentModalViewController:self.imagePickerController animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    self.selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.wordLimitLabel.text = [NSString stringWithFormat:@"%d",WORDSLIMIT - textView.text.length];
    
    if (textView.text.length > 0 || self.selectedImage != nil) {
        self.btnSend.enabled = YES;
    }
    else
    {
        self.btnSend.enabled = NO;
    }
    
    if (textView.text.length > WORDSLIMIT) {
        self.wordLimitLabel.textColor = [UIColor redColor];
    }
    else
    {
        self.wordLimitLabel.textColor = [UIColor blackColor];
    }

}


#pragma mark - SelectedImageViewControllerDelegate
- (void)didTouchedDeleteButton
{
    
    self.selectedImage = nil;
}


#pragma mark - EmotionSelectViewDelegate
- (void)didSelectEmotion:(NSString *)emotionText
{
    self.textView.text = [self.textView.text stringByAppendingString:emotionText];
    [self textViewDidChange:self.textView];
}

#pragma mark - MyLocationViewControllerDelegate

-(void)myLocationViewController:(MyLocationViewController *)locationController didSelectedLocationWithCoordinate:(CLLocationCoordinate2D)coordinate andAddress:(NSString *)address
{
    hasLocation = YES;
    self.address = self.locationLabel.text = address;
    _coordinate = coordinate;
    [locationController dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    hasLocation = NO;
    self.locationLabel.text = @"";
}
@end
