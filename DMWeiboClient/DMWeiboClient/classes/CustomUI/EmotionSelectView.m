//
//  EmotionSelectView.m
//  DMWeiboClient
//
//  Created by Blank on 13-1-16.
//  Copyright (c) 2013年 戴 立慧. All rights reserved.
//

#define EMOTION_PAGESIZE 28
#define EMOTION_ROWSIZE 4
#define EMOTION_COLSIZE 7
#define EMOTION_WIDTH 30

#import "EmotionSelectView.h"
@interface EmotionSelectView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *emotions;
@end


@implementation EmotionSelectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = (CGRect){self.frame.origin,320,216};
        self.backgroundColor = [UIColor grayColor];
        
        self.emotions = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist"]];
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"png != \"\""]];
        self.emotions = [self.emotions filteredArrayUsingPredicate:resultPredicate];
        
        NSInteger totalPage = self.emotions.count / EMOTION_PAGESIZE;
        if (self.emotions.count % EMOTION_PAGESIZE > 0) {
            totalPage +=1;
        }
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 200)];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * totalPage, self.scrollView.frame.size.height);
        self.scrollView.pagingEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        CGFloat margin = 15;
        CGFloat rowPadding = (self.scrollView.frame.size.height - margin - EMOTION_WIDTH * EMOTION_ROWSIZE) / (EMOTION_ROWSIZE -1);
        CGFloat colPadding = (self.scrollView.frame.size.width - margin *2 - EMOTION_WIDTH *EMOTION_COLSIZE) / (EMOTION_COLSIZE -1);

        for (int i = 0 ; i < self.emotions.count; i++) {
            NSInteger page = (i + 1) / EMOTION_PAGESIZE - 1;
            if ((i + 1) % EMOTION_PAGESIZE > 0) {
                page +=1;
            }
            
            NSInteger row = (i +1) / EMOTION_COLSIZE - 1;
            if ((i + 1) % EMOTION_COLSIZE > 0) {
                row +=1;
            }
            row = row - page * EMOTION_ROWSIZE;
            
            NSInteger col = i % EMOTION_COLSIZE;
            
            DebugLog(@"%d,%d,%d",page,row,col);
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(margin + col * (colPadding + EMOTION_WIDTH) + page * self.scrollView.frame.size.width, margin + row * (rowPadding + EMOTION_WIDTH), EMOTION_WIDTH, EMOTION_WIDTH);
            [button setImage:[UIImage imageNamed:[self.emotions[i] objectForKey:@"png"]] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(didTouchEmotionButton:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            [self.scrollView addSubview:button];
        }
        [self addSubview:self.scrollView];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:(CGRect){0,self.scrollView.frame.size.height,self.frame.size.width,self.frame.size.height - self.scrollView.frame.size.height}];
        self.pageControl.numberOfPages = totalPage;
        [self addSubview:self.pageControl];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    NSInteger page = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
    self.pageControl.currentPage = page;
}

- (void)didTouchEmotionButton:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectEmotion:)]) {
        [self.delegate didSelectEmotion:[self.emotions[sender.tag] objectForKey:@"chs"]];
    }
}
@end
