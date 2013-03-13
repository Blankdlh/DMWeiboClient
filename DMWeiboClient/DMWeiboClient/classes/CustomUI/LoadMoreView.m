//
//  LoadMoreView.m
//  DMWeiboClient
//
//  Created by 戴 立慧 on 12-11-1.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import "LoadMoreView.h"

@implementation LoadMoreView
@synthesize activityIndicator = _activityIndicator;
@synthesize loading = _loading;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {
        // Initialization code
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(200, 7, 30, 30)];
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(140, 7, 40, 30)];
        label.text = @"更多";
        [self addSubview:label];
        
        self.loading = NO;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

-(void)beginLoadMore
{
    [self addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    self.loading = YES;
    if ([self.delegate respondsToSelector:@selector(moreviewDidBeginLoad:)]) {
        [self.delegate moreviewDidBeginLoad:self];
    }
}

-(void)endLoadMore
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.loading = NO;
}

- (void)handleTapGesture:(UITapGestureRecognizer*)recognizer
{
    [self beginLoadMore];
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
