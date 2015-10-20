//
//  DemoViewController.m
//  FWDraggableSwipePlayer
//
//  Created by Filly Wang on 20/1/15.
//  Copyright (c) 2015 Filly Wang. All rights reserved.
//

#import "DemoViewController.h"
#import "FWSwipePlayerConfig.h"
#import "MovieDetailView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface DemoViewController ()
{
    NSMutableArray *list;
    BOOL shouldRotate;
    FWSwipePlayerViewController *playerController;
    BOOL isShowingStatusBar;
}

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.listView.delegate = self;
    self.listView.dataSource = self;
    
    shouldRotate = NO;
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"list" ofType:@"json"];
    NSData *listData=[NSData dataWithContentsOfFile:path];
    list = [NSJSONSerialization JSONObjectWithData:listData options:NSJSONReadingMutableLeaves error:nil];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tablecell"];
    
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tablecell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = list[[indexPath row]][@"title"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([indexPath row] == 0)
    {
        if(self.playerManager == nil)
        {
            FWSwipePlayerConfig *config = [[FWSwipePlayerConfig alloc]init];
            self.playerManager = [[FWDraggableManager alloc]initWithList:list Config:config];
        }
        else
            [self.playerManager updateInfo:list[[indexPath row]]];
        
        UIView *detailView = [[UIView alloc]init];
        detailView.backgroundColor = [UIColor blueColor];
        //[self.playerManager setDetailView:detailView];
        
         [[NSNotificationCenter defaultCenter] addObserver:self
         selector:@selector(handleSwipePlayerViewStateChange:)
         name:FWSwipePlayerViewStateChange object:nil];
        
        if(playerController != nil)
        {
            [playerController.moviePlayer stopAndRemove];
            playerController = nil;
        }
        
        [self.playerManager showAtViewAndPlay:self.view];
        
        
        self.listView.frame = CGRectMake(0, 20, self.listView.frame.size.width, self.view.frame.size.height);
        
    }
    else
    {
        if(self.playerManager)
        {
            [self.playerManager exit];
            self.playerManager = nil;
        }
        
        if(playerController != nil)
        {
            [playerController.moviePlayer stopAndRemove];
            playerController = nil;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSwipePlayerViewStateChange:)
                                                     name:FWSwipePlayerViewStateChange object:nil];
        
        shouldRotate = YES;
        
        playerController =  [[FWSwipePlayerViewController alloc]init];
        FWSwipePlayerConfig *config = [[FWSwipePlayerConfig alloc]init];

        NSMutableArray *dataList = [[NSMutableArray alloc]init] ;

        for(int i = (int)[indexPath row] ; i < [list count]; ++i)
        {
            [dataList addObject:list[i]];
        }
        
        config.draggable = NO;
        [playerController updateMoviePlayerWithVideoList:dataList Config:config];
        playerController.moviePlayer.delegate = self;
        [playerController attachTo:self];
        [playerController playStartAt:200];

        
        shouldRotate = NO;

    }
}

#pragma mark notification
-(void)handleSwipePlayerViewStateChange:(NSNotification *)notity
{
    BOOL isSmall = [[[notity userInfo] valueForKey:@"isSmall"] boolValue];
    BOOL isLock = [[[notity userInfo] valueForKey:@"isLock"] boolValue];
    
    if(isSmall || isLock)
        shouldRotate = NO;
    else if(!isLock && !isSmall)
        shouldRotate = YES;
    else
        shouldRotate = NO;
}

#pragma mark
-(void)doneBtnOnClick:(id)sender
{
    [self exitPlayer];
    
    shouldRotate = YES;
    [self setOrientation:UIDeviceOrientationPortrait];
    
    self.listView.frame = CGRectMake(0, 20, self.listView.frame.size.width, self.view.frame.size.height);
    
    shouldRotate = NO;
}

- (void)exitPlayer
{
    if(playerController)
    {
        [playerController stopAndRemove];
        playerController = nil;
    }
}

- (void)setOrientation:(int)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)setStatusBarHidden:(BOOL)hidden
{
    isShowingStatusBar = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return isShowingStatusBar;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    if(playerController != nil)
    {
        return playerController;
    }
    
    return nil;
}

#pragma mark rotata

- (BOOL)shouldAutorotate
{
    return shouldRotate;
}

@end
