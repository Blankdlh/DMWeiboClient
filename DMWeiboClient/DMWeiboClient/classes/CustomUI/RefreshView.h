//
//  RefreshView.h
//  DMWeiboClient
//
//  Created by 戴 立慧 on 12-10-30.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RefreshViewDelegate;

@interface RefreshView : UIView

@property (nonatomic, weak) id<RefreshViewDelegate> delegate;
@property (nonatomic) BOOL refreshing;

-(void)refreshViewDidScorll:(UIScrollView *)scrollView;//拖动时
-(void)refreshViewDidEndDragging:(UIScrollView *)scrollView;//松开时
-(void)refreshViewDidFinishLoading:(UIScrollView *)scrollView;//刷新完成时
@end




@protocol RefreshViewDelegate <NSObject>

@optional
-(void)refreshViewBeginRefreshing:(RefreshView *)refreshView;


@end