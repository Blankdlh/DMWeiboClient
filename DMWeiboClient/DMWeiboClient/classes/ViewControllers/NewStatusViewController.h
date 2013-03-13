//
//  NewStatusViewController.h
//  DMWeiboClient
//
//  Created by Blank on 13-1-15.
//  Copyright (c) 2013年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NewStatusViewControllerDelegate;
@interface NewStatusViewController : UIViewController
@property (nonatomic, weak) id<NewStatusViewControllerDelegate>delegate;
@end

@protocol NewStatusViewControllerDelegate <NSObject>

- (void)newStatusViewController:(NewStatusViewController*) viewcontroller dismissWithStatusInfo:(NSMutableDictionary*)userInfo;
@end