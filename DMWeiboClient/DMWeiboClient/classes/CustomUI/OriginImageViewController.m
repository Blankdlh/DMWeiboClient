//
//  OriginImageViewController.m
//  DMWeiboClient
//
//  Created by Blank on 12-12-28.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import "OriginImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface OriginImageViewController ()<UIScrollViewDelegate>
{
    BOOL isFullScreen;
}
@property (nonatomic, strong) UIProgressView *downloadProgress;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (strong, nonatomic)  UINavigationBar *navBar;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *lodingLabel;
@end

@implementation OriginImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];
    DebugLog(@"%@",self.view);
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    isFullScreen = NO;
    self.wantsFullScreenLayout = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navBar =[[UINavigationBar alloc] initWithFrame:(CGRect){0,STATUEBAR_HEIGHT,self.view.frame.size.width, NAV_HEIGHT}];
    self.navBar.barStyle = UIBarStyleBlack;
    UINavigationItem *navItem = [[UINavigationItem alloc]init];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(btnCloseTouched:)];

    navItem.leftBarButtonItem = leftItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(btnSaveTouched:)];

    navItem.rightBarButtonItem = rightItem;
    [self.navBar setItems:[NSArray arrayWithObject:navItem]];
    [self.view addSubview:self.navBar];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT)];
    self.scrollView.delegate = self;
    [self.view insertSubview:self.scrollView belowSubview:self.navBar];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNavBar)];
    [self.scrollView addGestureRecognizer:recognizer];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 235) / 2 , (VIEW_HEGHT - 235) / 2 + STATUEBAR_HEIGHT + NAV_HEIGHT, 235, 235)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
    
    self.downloadProgress = [[UIProgressView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200) / 2 , (VIEW_HEGHT - 5) / 2+ STATUEBAR_HEIGHT + NAV_HEIGHT, 200, 5)];
    self.downloadProgress.progressViewStyle = UIProgressViewStyleBar;
    self.downloadProgress.trackTintColor = [UIColor clearColor];
    [self.scrollView addSubview:self.downloadProgress];
    DebugLog(@"%@",self.downloadProgress);
    
    self.lodingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.downloadProgress.frame.origin.y - 21, self.scrollView.frame.size.width, 21)];
    self.lodingLabel.textAlignment = UITextAlignmentCenter;
    self.lodingLabel.textColor = [UIColor whiteColor];
    self.lodingLabel.backgroundColor = [UIColor clearColor];
    self.lodingLabel.text = @"0%%";
    [self.scrollView addSubview:self.lodingLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    __block OriginImageViewController *blockSelf = self;
    
    [self.imageView setImageWithURL:[NSURL URLWithString:self.originImageURL] placeholderImage:[UIImage imageNamed:@"photo_loading"] options:0 progress:^(NSUInteger receivedSize, long long expectedSize){
        CGFloat temp = receivedSize * 1.0/expectedSize;
        temp = temp > 0 ? temp : 0;
        [blockSelf.downloadProgress setProgress:temp animated:YES];
        blockSelf.lodingLabel.text = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:temp] numberStyle:NSNumberFormatterPercentStyle];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
    {
        if (error) {
            DebugLog(@"download error");
            blockSelf.lodingLabel.text = @"加载失败";
        }else
        {
            [blockSelf.downloadProgress removeFromSuperview];
            [blockSelf.lodingLabel removeFromSuperview];
            blockSelf.imageView.alpha = 0;
            
            [UIView animateWithDuration:.4f animations:^{
                BOOL imageIsLandscape = NO;
                if (image.size.width > image.size.height) {
                    imageIsLandscape = YES;
                }
                if (imageIsLandscape) {
                    blockSelf.imageView.frame = blockSelf.scrollView.bounds;
                }
                else
                {
                    CGFloat height;
                    if(image.size.width > blockSelf.scrollView.frame.size.width){
                        height = image.size.height * blockSelf.scrollView.frame.size.width / image.size.width;
                    }
                    else
                        height = image.size.height;
                    if (height < blockSelf.scrollView.bounds.size.height) {
                        height = blockSelf.scrollView.bounds.size.height;
                    }
                    blockSelf.imageView.frame = CGRectMake(0, 0, blockSelf.scrollView.frame.size.width, height);
                }
                blockSelf.imageView.alpha = 1;
                
            } completion:^(BOOL finished){
                blockSelf.scrollView.contentSize = blockSelf.imageView.bounds.size;
                [blockSelf.scrollView setMaximumZoomScale: image.size.width > blockSelf.scrollView.bounds.size.width ? image.size.width / blockSelf.scrollView.bounds.size.width:2.0];
                [blockSelf.scrollView setMinimumZoomScale:1];
                blockSelf.navBar.alpha = 0.7;
                [UIApplication sharedApplication].statusBarStyle= UIStatusBarStyleBlackTranslucent;
                [blockSelf performSelector:@selector(hideNavBar) withObject:nil afterDelay:3];
            }];
            DebugLog(@"%@",blockSelf.imageView);
        }
    }];
    
}
- (void)btnCloseTouched:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    isFullScreen = YES;
    self.wantsFullScreenLayout = YES;
    if([self.delegate respondsToSelector:@selector(dismiss)])
    {
        [self.delegate dismiss];
    }
}
- (void)btnSaveTouched:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.imageView.image,self,@selector(image: didFinishSavingWithError: contextInfo:),nil);
    DebugLog(@"save");
}

- (void)viewDidUnload {
    [self setNavBar:nil];
    [super viewDidUnload];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
//    CGFloat visibleWidth = scrollView.zoomScale * self.imageView.frame.size.width;
//    if (visibleWidth < scrollView.frame.size.width) {
//        self.imageView.frame = (CGRect){(1 - scrollView.zoomScale) * scrollView.bounds.size.width,(1-scrollView.zoomScale) * scrollView.bounds.size.height,self.imageView.bounds.size};
//    }
    DebugLog(@"%@",self.imageView);
}

#pragma mark - CustomMethod
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    DebugLog(@"saved");
}

- (void)hideNavBar
{
    if (!isFullScreen) {
        [UIView animateWithDuration:.5f animations:^(){
            self.navBar.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        } completion:^(BOOL finished){
            isFullScreen = YES;
        }];
    }

    
}

- (void)showNavBar
{
    if (isFullScreen) {
        [UIView animateWithDuration:.5f animations:^(){
            self.navBar.alpha = 0.7;
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        } completion:^(BOOL finished){
            isFullScreen = NO;
            [self performSelector:@selector(hideNavBar) withObject:nil afterDelay:3];
        }];
    }

}
@end
