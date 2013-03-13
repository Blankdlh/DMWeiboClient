//
//  MyLocationViewController.h
//  DMWeiboClient
//
//  Created by Blank on 13-1-17.
//  Copyright (c) 2013年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol MyLocationViewControllerDelegate;
@interface MyLocationViewController : UIViewController
@property (nonatomic,weak) id<MyLocationViewControllerDelegate> delegate;
@end

@protocol MyLocationViewControllerDelegate <NSObject>

- (void)myLocationViewController:(MyLocationViewController*)locationController didSelectedLocationWithCoordinate:(CLLocationCoordinate2D)coordinate andAddress:(NSString*)address;

@end