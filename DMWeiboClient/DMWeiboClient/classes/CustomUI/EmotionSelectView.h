//
//  EmotionSelectView.h
//  DMWeiboClient
//
//  Created by Blank on 13-1-16.
//  Copyright (c) 2013年 戴 立慧. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EmotionSelectViewDelegate;
@interface EmotionSelectView : UIView
@property (nonatomic, weak) id<EmotionSelectViewDelegate> delegate;
@end

@protocol EmotionSelectViewDelegate <NSObject>

- (void)didSelectEmotion:(NSString*)emotionText;

@end