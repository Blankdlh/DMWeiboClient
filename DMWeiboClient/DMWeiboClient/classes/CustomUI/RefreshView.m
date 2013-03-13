//
//  RefreshView.m
//  DMWeiboClient
//
//  Created by 戴 立慧 on 12-10-30.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import "RefreshView.h"

#define HEIGHT 50

@interface RefreshView()

@property (nonatomic, strong)UIActivityIndicatorView * activityIndicator;
@property (nonatomic, strong)UILabel * label;

@end

@implementation RefreshView
@synthesize delegate = _delegate, activityIndicator = _activityIndicator;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, -HEIGHT, 320, HEIGHT)];
    if (self) {
        // Initialization code
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, 100, 30)];
        [self addSubview:_label];
        
        self.refreshing = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)refreshViewDidScorll:(UIScrollView *)scrollView
{
    if (!self.refreshing) {
        if (scrollView.contentOffset.y < 0 && scrollView.contentOffset.y > -HEIGHT) {
            self.label.text = @"下拉刷新";
        }
        else if(scrollView.contentOffset.y < -HEIGHT)
        {
            self.label.text = @"松开刷新";
        }
        
    }
}

-(void)refreshViewDidEndDragging:(UIScrollView *)scrollView
{
    if (!self.refreshing && scrollView.contentOffset.y < -HEIGHT) {
        [self addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
        self.label.text = @"正在刷新";
        
        scrollView.contentInset = UIEdgeInsetsMake(HEIGHT, 0, 0, 0);
        self.refreshing = YES;
        if ([self.delegate respondsToSelector:@selector(refreshViewBeginRefreshing:)]) {
            [self.delegate refreshViewBeginRefreshing:self];
        }
    }
}

-(void)refreshViewDidFinishLoading:(UIScrollView *)scrollView
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.refreshing = NO;
    scrollView.contentInset = UIEdgeInsetsZero;
    
}
@end
