//
//  MainTabBarController.m
//  DMWeiboClient
//
//  Created by Blank on 12-12-26.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import "MainTabBarController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

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
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        switch (i) {
            case 0:
                [item setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_home_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_home"]];
                break;
            case 1:
                [item setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_message_center_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_message_center"]];
                break;
            case 2:
                [item setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_profile_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_profile"]];
                break;
            case 3:
                [item setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_discover_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_discover"]];
                break;
            case 4:
                [item setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_more_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_more"]];
                break;
            default:
                break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
