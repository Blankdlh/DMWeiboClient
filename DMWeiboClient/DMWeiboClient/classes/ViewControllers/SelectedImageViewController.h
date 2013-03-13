//
//  SelectedImageViewController.h
//  DMWeiboClient
//
//  Created by Blank on 13-1-16.
//  Copyright (c) 2013年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectedImageViewControllerDelegate;
@interface SelectedImageViewController : UIViewController
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, weak) id<SelectedImageViewControllerDelegate> delegate;
@end

@protocol SelectedImageViewControllerDelegate <NSObject>

- (void)didTouchedDeleteButton;

@end