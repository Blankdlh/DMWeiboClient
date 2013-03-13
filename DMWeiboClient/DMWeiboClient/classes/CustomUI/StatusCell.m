//
//  StatusCell.m
//  DMWeiboClient
//
//  Created by Blank on 12-12-21.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import "StatusCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "PopImageView.h"
#import "CustomStatusBar.h"

@interface StatusCell()
@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UIButton *statusImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *avaterTagImage;
@property (weak, nonatomic) IBOutlet UIImageView *retweetBGImage;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *originImageURL;
@property (nonatomic, strong) NSString *middleImageURL;
@property (nonatomic, strong) PopImageView *popImageView;
@property (weak, nonatomic) IBOutlet UIImageView *retweetImage;
@property (weak, nonatomic) IBOutlet UILabel *repostLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentImage;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end

@implementation StatusCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStatus:(NSDictionary *)status
{
    _status = status;
    [self configSubviews];
}


-(void)configSubviews
{
    self.retweetLabel.hidden = YES;
    self.retweetBGImage.hidden = YES;
    self.statusImage.hidden = self.statusImageButton.hidden = YES;
    
    CGFloat margin = 10;
    self.usernameLabel.text = [self.status valueForKeyPath:@"user.screen_name"];
    self.statusLabel.text = [self.status objectForKey:@"text"];
    self.timeLabel.text = [self getStatusCreateDateString:[self.status objectForKey:@"created_at"]];
    self.sourceLabel.text = [self getStatusSource: [self.status objectForKey:@"source"]];
    
    self.avaterImage.layer.borderColor = [[UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:0.5] CGColor];
    self.avaterImage.layer.cornerRadius = 6;
    self.avaterImage.layer.borderWidth = 1;
    self.avaterImage.clipsToBounds = YES;
    [self.avaterImage setImageWithURL:[self.status valueForKeyPath:@"user.avatar_large"] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    if ([[[self.status valueForKeyPath:@"user.verified"] stringValue] isEqualToString:@"1"]) {
        [self.avaterTagImage setImage:[UIImage imageNamed:@"avatar_vip"]];
        self.avaterTagImage.hidden = NO;
    }
    else
        self.avaterTagImage.hidden = YES;
    
    //内容
    self.statusLabel.frame = (CGRect){self.statusLabel.frame.origin, self.statusLabel.bounds.size.width, self.statusHeight};
    
    CGFloat yoffset = self.statusLabel.frame.origin.y + self.statusHeight;
    
    CGFloat retweetMargin = 5;
    //是否转发
    if([self.status valueForKeyPath:@"retweeted_status"])
    {
        yoffset += retweetMargin;
        CGFloat tempOffset = yoffset;
        self.retweetBGImage.image = [[UIImage imageNamed:@"timeline_retweet_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 25, 4, 4)];
        
        yoffset += margin;
        self.retweetLabel.frame = CGRectMake(self.statusLabel.frame.origin.x +6, yoffset, self.statusLabel.frame.size.width -8, self.retweetHeight);
        self.retweetLabel.text = [NSString stringWithFormat:@"@%@:%@",[self.status valueForKeyPath:@"retweeted_status.user.screen_name"],[self.status valueForKeyPath:@"retweeted_status.text"]];
        yoffset += self.retweetHeight;
        
        if ([self.status valueForKeyPath:@"retweeted_status.thumbnail_pic"]){
            yoffset += retweetMargin;
            [self imageWithFrame:CGRectMake(self.retweetLabel.frame.origin.x, yoffset, TIMELINE_IMAGE_SIZE, TIMELINE_IMAGE_SIZE) withImageURL:[self.status valueForKeyPath:@"retweeted_status.thumbnail_pic"] andMiddleImageURL:[self.status valueForKeyPath:@"retweeted_status.bmiddle_pic"] andOriginImageURL:[self.status valueForKeyPath:@"retweeted_status.original_pic"]];
            yoffset += self.statusImage.frame.size.height;
        }
        yoffset += retweetMargin;
        self.retweetBGImage.frame = CGRectMake(self.statusLabel.frame.origin.x, tempOffset, self.statusLabel.frame.size.width, yoffset - tempOffset);
        self.retweetLabel.hidden = NO;
        self.retweetBGImage.hidden = NO;
    }
    
    //图片
    if([self.status valueForKeyPath:@"thumbnail_pic"])
    {
        yoffset +=margin;
        [self imageWithFrame:CGRectMake(self.statusImage.frame.origin.x, yoffset, TIMELINE_IMAGE_SIZE, TIMELINE_IMAGE_SIZE) withImageURL:[self.status valueForKeyPath:@"thumbnail_pic"] andMiddleImageURL:[self.status valueForKeyPath:@"bmiddle_pic"] andOriginImageURL:[self.status valueForKeyPath:@"original_pic"]];
        yoffset += self.statusImage.frame.size.height;
    }
    
    yoffset +=margin;
    
    self.timeLabel.frame = (CGRect){self.timeLabel.frame.origin.x,  yoffset, self.timeLabel.frame.size};
    
    self.sourceLabel.frame = (CGRect){self.sourceLabel.frame.origin.x, yoffset, self.sourceLabel.frame.size};
    
    //评论转发数 reposts_count comments_count
    CGFloat xoffset = self.frame.size.width -10;
    UIFont *contFont = [UIFont systemFontOfSize:8.0];
    if ([[self.status valueForKeyPath:@"comments_count"] integerValue] > 0) {
        
        self.commentLabel.text = [[self.status valueForKeyPath:@"comments_count"] stringValue];
        DebugLog(@"%@",self.commentLabel.text);
        
        CGSize size = [self.commentLabel.text sizeWithFont:contFont];
        size.width +=10;
        self.commentLabel.frame = (CGRect){xoffset - size.width, 16, size};
        xoffset -= size.width;
        xoffset -= 2;
        self.commentImage.frame = (CGRect){xoffset - self.commentImage.frame.size.width, 15, self.commentImage.frame.size};
        
        xoffset -= self.commentImage.frame.size.width;
        
        self.commentLabel.hidden = NO;
        self.commentImage.hidden = NO;
        
    }
    else
    {
        self.commentLabel.hidden = YES;
        self.commentImage.hidden = YES;
    }
    
    if ([[self.status valueForKeyPath:@"reposts_count"] integerValue] > 0) {
        self.repostLabel.text = [[self.status valueForKeyPath:@"reposts_count"] stringValue];
        DebugLog(@"%@",self.repostLabel.text);
        
        xoffset -=5;
        CGSize size = [self.repostLabel.text sizeWithFont:contFont];
        size.width +=10;
        self.repostLabel.frame = (CGRect){xoffset - size.width, 16, size};
        xoffset -= size.width;
        xoffset -= 2;
        self.retweetImage.frame = (CGRect){xoffset - self.commentImage.frame.size.width, 15, self.commentImage.frame.size};
        
        self.repostLabel.hidden = NO;
        self.retweetImage.hidden = NO;
    }
    else
    {
        self.repostLabel.hidden = YES;
        self.retweetImage.hidden = YES;
    }
}

- (PopImageView*)popImageView
{
    if (!_popImageView) {
        _popImageView = [[PopImageView alloc] init];
    }
    return _popImageView;
}

- (NSString *)getStatusCreateDateString:(NSString *)gmtDateString
{
    NSString *strSendDate = @"";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE MMM d HH:mm:ss Z yyyy"];
    formatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDate *sendDate = [formatter dateFromString:gmtDateString];
    NSDate *nowDate = [NSDate date];
    
    NSTimeInterval timeInterval = [nowDate timeIntervalSinceDate:sendDate];
    
    if (timeInterval <60) {
        strSendDate = [NSString stringWithFormat:@"%d秒之前",(int)timeInterval];
    }
    else if(timeInterval >= 60 && timeInterval < 60*60 )
    {
        strSendDate = [NSString stringWithFormat:@"%d分钟之前",(int)timeInterval / 60];
    }
    else if(timeInterval >= 60*60 && timeInterval < 60*60*24)
    {
        strSendDate = [NSString stringWithFormat:@"%d小时之前",(int)timeInterval / 60 /60];
    }
    else
    {
        [formatter setDateFormat:@"MM-dd HH:mm"];
        strSendDate = [formatter stringFromDate:sendDate];
    }
    return strSendDate;
}

- (NSString*)getStatusSource:(NSString*)originString
{
    NSInteger index = [originString rangeOfString:@">"].location;
    NSRange range;
    range.location = index +1;
    range.length = originString.length - index -1 -4;
    NSString *result = [NSString stringWithFormat:@"来自%@", [originString substringWithRange:range]];
    return result;
}
- (IBAction)didTouchedStatusImage:(id)sender {
    
    [self.popImageView showWithThumImageURL:self.middleImageURL andOriginImageURL:self.originImageURL];
    DebugLog(@"%@",self.imageURL);
}

- (void)imageWithFrame:(CGRect)frame withImageURL:(id)url andMiddleImageURL:(NSString*)middleUrl andOriginImageURL:(NSString*)originUrl
{
    self.statusImage.frame = frame;
    self.statusImageButton.frame = self.statusImage.frame;
    [self.statusImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"timeline_image_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        if (!error) {
            self.statusImage.alpha = 0;
            [UIView animateWithDuration:.3f animations:^(){
                self.statusImage.alpha = 1;
            }];
        }
    }];

    self.imageURL = url;
    self.middleImageURL = middleUrl;
    self.originImageURL = originUrl;
    self.statusImage.hidden = self.statusImageButton.hidden =NO;
}
@end
