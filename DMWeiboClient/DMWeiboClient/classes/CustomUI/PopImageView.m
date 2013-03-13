//
//  PopImageView.m
//  DMWeiboClient
//
//  Created by Blank on 12-12-25.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import "PopImageView.h"
#import "ThumbImageViewController.h"
#import "OriginImageViewController.h"

#pragma mark - OriginImageViewController

@interface PopImageView()<ThumbImageViewDelegate>
@property (nonatomic, strong) NSString *thumbImageURL;
@property (nonatomic, strong) NSString *originImageURL;
@property (nonatomic, strong) ThumbImageViewController* thumbView;
@end

@implementation PopImageView


-(void)showWithThumImageURL:(NSString*)thumbImageURL andOriginImageURL:(NSString*)originImageURL
{
    self.thumbImageURL = thumbImageURL;
    self.originImageURL = originImageURL;
    self.thumbView = [[ThumbImageViewController alloc]init];
    self.thumbView.delegate = self;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.thumbView.view];
    self.thumbView.view.alpha = 0;
    [UIView animateWithDuration:.5 animations:^(){
        self.thumbView.view.alpha = 1;
    }];
}

- (void)didTouchButton
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

