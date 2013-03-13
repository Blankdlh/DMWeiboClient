//
//  AppDelegate.h
//  DMWeiboClient
//
//  Created by 戴 立慧 on 12-10-18.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

#define kAppKey             @"2991378770"
#define kAppSecret          @"e4ce5e41fa8e7d064200d1c1e0ebd548"
#define kAppRedirectURI     @"http://myfirstsaeapp.sinaapp.com/callback.php"

#ifndef kAppKey
#error
#endif

#ifndef kAppSecret
#error
#endif

#ifndef kAppRedirectURI
#error
#endif


@class SinaWeibo;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic) SinaWeibo *sinaweibo;
@property (strong, nonatomic) ViewController *loginViewController;
@end
