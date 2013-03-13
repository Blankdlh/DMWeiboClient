//
//  OriginImageViewController.h
//  DMWeiboClient
//
//  Created by Blank on 12-12-28.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OriginImageViewDelegate;

@interface OriginImageViewController:UIViewController
@property (nonatomic, strong) NSString *originImageURL;
@property (nonatomic, weak) id<OriginImageViewDelegate>delegate;
@end

@protocol OriginImageViewDelegate <NSObject>
- (void)dismiss;
@end