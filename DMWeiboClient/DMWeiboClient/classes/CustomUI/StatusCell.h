//
//  StatusCell.h
//  DMWeiboClient
//
//  Created by Blank on 12-12-21.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusCell : UITableViewCell
@property (nonatomic, strong)NSDictionary *status;
@property (nonatomic)CGFloat statusHeight;
@property (nonatomic)CGFloat retweetHeight;

@end
