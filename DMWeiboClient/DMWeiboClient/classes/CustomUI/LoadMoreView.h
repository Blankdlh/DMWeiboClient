//
//  LoadMoreView.h
//  DMWeiboClient
//
//  Created by 戴 立慧 on 12-11-1.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadMoreViewDelegate;
@interface LoadMoreView : UIView

@property (nonatomic, strong)UIActivityIndicatorView *activityIndicator;
@property (nonatomic)BOOL loading;
@property (nonatomic, weak) id<LoadMoreViewDelegate>delegate;
-(void)beginLoadMore;
-(void)endLoadMore;
@end


@protocol LoadMoreViewDelegate <NSObject>

- (void)moreviewDidBeginLoad:(LoadMoreView*)view;

@end