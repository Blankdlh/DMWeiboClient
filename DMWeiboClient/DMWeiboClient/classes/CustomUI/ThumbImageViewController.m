//
//  ThumbImageViewController.m
//  DMWeiboClient
//
//  Created by Blank on 12-12-28.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import "ThumbImageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "OriginImageViewController.h"

@interface ThumbImageViewController ()<OriginImageViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *watchButton;
@end

@implementation ThumbImageViewController

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
	// Do any additional setup after loading the view.
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
    //初始化大小
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    
    //遮罩层
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = .7;
    [self.view addSubview:overlayView];
    
    //底部按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(didTouchButton) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 150, 33);
    [button setTitle:@"查看原图" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:@"preview_originalbutton_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:@"preview_originalbutton_background_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)]forState:UIControlStateHighlighted];
    
    self.watchButton = button;
    UIBarButtonItem   *watchButton=[[UIBarButtonItem alloc]  initWithCustomView:button];
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - TABBAR_HEIGHT, self.view.frame.size.width, TABBAR_HEIGHT)];
    
    [bottomBar setItems:[NSArray arrayWithObjects:spaceButtonItem, watchButton, spaceButtonItem, nil]];
    [bottomBar setBackgroundImage:[UIImage imageNamed:@"preview_toolbar_background"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [self.view addSubview:bottomBar];
    
    //触摸手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    //菊花
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 50) / 2, (VIEW_HEGHT - 50) / 2, 50, 50)];
    [self.activityIndicator startAnimating];
    
    //图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 70) / 2, (VIEW_HEGHT - 70) / 2, 70, 70)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.borderWidth = 2;
    imageView.layer.borderColor = [[UIColor colorWithWhite:0.3 alpha:0.5] CGColor];
    imageView.layer.shadowOffset = CGSizeMake(0, 3);
    imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    imageView.layer.shadowOpacity = 0.8;
    imageView.layer.shadowRadius=10.0;
    self.imageView = imageView;
    DebugLog(@"%@",[self.delegate thumbImageURL]);
    __block ThumbImageViewController *blockSelf = self;
    [self.imageView setImageWithURL:[NSURL URLWithString:[self.delegate thumbImageURL]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        [blockSelf.activityIndicator stopAnimating];
        [blockSelf.activityIndicator removeFromSuperview];
        blockSelf.imageView.layer.borderWidth = 0;
        CGFloat height = blockSelf.view.bounds.size.height - TABBAR_HEIGHT -50;
        [UIView animateWithDuration:.3f animations:^(){
            blockSelf.imageView.frame = CGRectMake((blockSelf.view.frame.size.width - 260) / 2, (blockSelf.view.frame.size.height - TABBAR_HEIGHT - height) / 2, 260, height);
        }];
        
    }];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.activityIndicator];
    
    
}

- (void)dismiss
{
    [UIView animateWithDuration:.5 animations:^(){
        self.view.alpha = 0;
        
    } completion:^(BOOL complete){
        [self.view removeFromSuperview];
    }];
    
}

- (void)handleTapGesture:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self dismiss];
    }

}

- (void)didTouchButton
{
    OriginImageViewController *originView = [[OriginImageViewController alloc] init];
    originView.originImageURL = [self.delegate originImageURL];
    originView.delegate = self;
    [self presentModalViewController:originView animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ((touch.view == self.watchButton)) {//屏蔽按钮tap手势
        return NO;
    }
    return YES;
}

@end

