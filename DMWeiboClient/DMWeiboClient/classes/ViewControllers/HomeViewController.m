//
//  HomeViewController.m
//  DMWeiboClient
//
//  Created by 戴 立慧 on 12-10-29.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "RefreshView.h"
#import "LoadMoreView.h"
#import "StatusCell.h"
#import "NewStatusViewController.h"
#import "CustomStatusBar.h"

#define PAGESIZE 25
@interface HomeViewController ()<SinaWeiboRequestDelegate, RefreshViewDelegate, LoadMoreViewDelegate, NewStatusViewControllerDelegate>
@property (nonatomic, readonly)SinaWeibo *sinaweibo;
@property (nonatomic, strong)NSDictionary *userInfo;
@property (nonatomic, strong)NSArray *statuses;

@property (nonatomic, strong)RefreshView *refreshView;
@property (nonatomic, strong)LoadMoreView *loadMoreView;

@property (nonatomic, strong)NSArray *heightArray;
@property (nonatomic, strong)NSArray *retweetHeightArray;

@property (nonatomic, strong)NewStatusViewController *newstatusViewController;
@end

@implementation HomeViewController

-(NSArray *)statuses
{
    if (!_statuses) {
        _statuses = [NSArray array];
    }
    return _statuses;
}

- (SinaWeibo *)sinaweibo
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.sinaweibo;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *newWeiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newWeiboButton setBackgroundImage:[UIImage imageNamed:@"navigationbar_compose"] forState:UIControlStateNormal];
    [newWeiboButton addTarget:self action:@selector(createNewStatus) forControlEvents:UIControlEventTouchUpInside];
    newWeiboButton.frame = CGRectMake(0, 0, 24, 24);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:newWeiboButton];
    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setBackgroundImage:[UIImage imageNamed:@"navigationbar_refresh"] forState:UIControlStateNormal];
    refreshButton.frame = CGRectMake(0, 0, 24, 24);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:refreshButton];
    
    _refreshView = [[RefreshView alloc] initWithFrame:CGRectMake(0, -70, 320, 70)];
    self.refreshView.delegate = self;
    self.refreshView.refreshing = YES;
    [self.view addSubview:self.refreshView];
    
    _loadMoreView = [[LoadMoreView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.loadMoreView.delegate = self;
    
    [self.sinaweibo requestWithURL:@"users/show.json"
                            params:[NSMutableDictionary dictionaryWithObject:self.sinaweibo.userID forKey:@"uid"]
                        httpMethod:@"GET"
                          delegate:self];
    
    [self.sinaweibo requestWithURL:@"statuses/home_timeline.json"
                            params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",PAGESIZE], @"count", nil]
                        httpMethod:@"GET"
                          delegate:self];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewStatus"]) {
        self.newstatusViewController = segue.destinationViewController;
        self.newstatusViewController.delegate = self;
    }
}

#pragma mark - custom methods


- (void)createNewStatus
{
    [self performSegueWithIdentifier:@"NewStatus" sender:self];
}


- (void)caculateHeight:(NSArray*)statuses appendToEnd:(BOOL) appendToEnd
{
    NSMutableArray *heightArray = [NSMutableArray array];
    NSMutableArray *retweetHeightArray = [NSMutableArray array];
    CGFloat height = 0;
    for (NSDictionary *status in statuses) {
        
        //主内容
        NSString *content = [status valueForKeyPath:@"text"];
        UIFont *font = [UIFont systemFontOfSize:16.0];
        CGSize size = CGSizeMake(254,2000);
        CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
        height = labelsize.height;
        [heightArray addObject:[NSNumber numberWithFloat:height]];
        
        if ([status valueForKeyPath:@"retweeted_status"]) {
            NSString *retweetContent = [NSString stringWithFormat:@"@%@:%@",[status valueForKeyPath:@"retweeted_status.user.screen_name"],[status valueForKeyPath:@"retweeted_status.text"]];
            UIFont *retweetFont = [UIFont systemFontOfSize:14.0];
            CGSize retweetSize = CGSizeMake(240,2000);
            labelsize = [retweetContent sizeWithFont:retweetFont constrainedToSize:retweetSize lineBreakMode:UILineBreakModeWordWrap];
            height = labelsize.height;
            DebugLog(@"%@",retweetContent);
        }
        else
            height = 0;
        //转发内容
        
        [retweetHeightArray addObject:[NSNumber numberWithFloat:height]];
    }
    if (appendToEnd) {
        self.heightArray = [self.heightArray arrayByAddingObjectsFromArray:heightArray];
        self.retweetHeightArray = [self.retweetHeightArray arrayByAddingObjectsFromArray:retweetHeightArray];
    }
    else {
        self.heightArray = [heightArray arrayByAddingObjectsFromArray:self.heightArray];
        self.retweetHeightArray = [retweetHeightArray arrayByAddingObjectsFromArray:self.retweetHeightArray];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    DebugLog(@"%d",self.statuses.count);
    return self.statuses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StatusCell";
    StatusCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.statusHeight = [self.heightArray[indexPath.row] floatValue];
    cell.retweetHeight = [self.retweetHeightArray[indexPath.row] floatValue];
    cell.status = [self.statuses objectAtIndex:indexPath.row];
//    DebugLog(@"%@",cell.status);
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *status = self.statuses[indexPath.row];
    CGFloat height = [self.heightArray[indexPath.row] floatValue];
    if ([status valueForKeyPath:@"thumbnail_pic"]) {
        height += TIMELINE_IMAGE_SIZE +10;
    }
    if ([status valueForKeyPath:@"retweeted_status"]) {
        height += [self.retweetHeightArray[indexPath.row] floatValue] + 10;
        if ([status valueForKeyPath:@"retweeted_status.thumbnail_pic"]) {
            height += TIMELINE_IMAGE_SIZE +10;
        }
        height +=10;
    }
    height += 70;
    return height;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - SinaWeiboRequestDelegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        self.userInfo = nil;
    }
    else if ([request.url hasSuffix:@"statuses/home_timeline.json"])
    {
        self.statuses = nil;
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        [CustomStatusBar showStatusMessage:@"发送失败" autoDismiss:YES];
    }
    else if ([request.url hasSuffix:@"statuses/update.json"])
    {
        [CustomStatusBar showStatusMessage:@"发送失败" autoDismiss:YES];
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        self.userInfo = result;
        self.navigationItem.title = [result objectForKey:@"screen_name"];
        
    }
    else if ([request.url hasSuffix:@"statuses/home_timeline.json"])
    {
        NSLog(@"new %d",[[result objectForKey:@"statuses"] count]);
        NSMutableArray *array = [[result objectForKey:@"statuses"] mutableCopy];
        if (self.refreshView.refreshing) {
            
            if (array.count < PAGESIZE) {
                NSMutableArray *indexArray = [NSMutableArray array];
                for (int i = 0; i < array.count; i++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [indexArray addObject:indexPath];
                }
                self.statuses = [array arrayByAddingObjectsFromArray:self.statuses];
                [self caculateHeight:array appendToEnd:NO];
                [self.tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
            }
            else
            {
                self.statuses = array;
                self.heightArray = [NSArray array];
                self.retweetHeightArray = [NSArray array];
                [self caculateHeight:array appendToEnd:YES];
                [self.tableView reloadData];
            }
            [self.refreshView refreshViewDidFinishLoading:self.tableView];
            
        }
        else //加载更多
        {
            [array removeObjectAtIndex:0];
            [self caculateHeight:array appendToEnd:YES];
            
            NSMutableArray *indexArray = [NSMutableArray array];
            for (int i = 0; i < array.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.statuses.count +i inSection:0];
                [indexArray addObject:indexPath];
            }
            
            self.statuses = [self.statuses arrayByAddingObjectsFromArray:array];
            
            
            [self.tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
            [self.loadMoreView endLoadMore];
        }
        self.tableView.tableFooterView = self.loadMoreView;
        
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        [CustomStatusBar showStatusMessage:@"发送成功!" autoDismiss:YES];
    }
    else if ([request.url hasSuffix:@"statuses/update.json"])
    {
        [CustomStatusBar showStatusMessage:@"发送成功!" autoDismiss:YES];
    }
    
}

#pragma mark - scrollviewdelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshView refreshViewDidScorll:scrollView];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshView refreshViewDidEndDragging:scrollView];
    if (!self.refreshView.refreshing && !self.loadMoreView.loading && self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height) {
        [self.loadMoreView beginLoadMore];
        NSLog(@"%@",[self.statuses.lastObject objectForKey:@"id"]);
    }
}

#pragma mark - RefreshViewDelegate

-(void)refreshViewBeginRefreshing:(RefreshView *)refreshView
{
    [self.loadMoreView endLoadMore];
    [self.sinaweibo requestWithURL:@"statuses/home_timeline.json"
                            params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[[self.statuses objectAtIndex:0]  objectForKey:@"id"] stringValue], @"since_id", [NSString stringWithFormat:@"%d",PAGESIZE], @"count", nil]
                        httpMethod:@"GET"
                          delegate:self];
}


#pragma mark - LoadMoreViewDelegate

- (void)moreviewDidBeginLoad:(LoadMoreView *)view
{
    [self.sinaweibo requestWithURL:@"statuses/home_timeline.json"
                            params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[self.statuses.lastObject objectForKey:@"id"] stringValue], @"max_id", [NSString stringWithFormat:@"%d",PAGESIZE+1], @"count", nil]
                        httpMethod:@"GET"
                          delegate:self];

}

#pragma mark - NewStatusViewControllerDelegate
- (void)newStatusViewController:(NewStatusViewController *)viewcontroller dismissWithStatusInfo:(NSMutableDictionary *)userInfo
{
    [self.newstatusViewController dismissModalViewControllerAnimated:YES];
    SinaWeibo *sinaweibo = [self sinaweibo];
    [CustomStatusBar showStatusMessage:@"正在发送..." autoDismiss:NO];
    NSString *url = @"";
    if ([userInfo objectForKey:@"pic"]) {//有图片
        url = @"statuses/upload.json";
    }
    else
        url = @"statuses/update.json";
    
    [sinaweibo requestWithURL:url
                       params:userInfo
                   httpMethod:@"POST"
                     delegate:self];
}
@end
