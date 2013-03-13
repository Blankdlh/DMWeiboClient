//
//  ThumbImageViewController.h
//  DMWeiboClient
//
//  Created by Blank on 12-12-28.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThumbImageViewDelegate;

@interface ThumbImageViewController:UIViewController
@property (nonatomic, weak) id<ThumbImageViewDelegate>delegate;

@end

@protocol ThumbImageViewDelegate <NSObject>
- (NSString*)originImageURL;
- (NSString*)thumbImageURL;
@end