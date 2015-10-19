//
//  FWSwipePlayerNavLayer.m
//  FWDraggableSwipePlayer
//
//  Created by Filly Wang on 9/3/15.
//  Copyright (c) 2015 Filly Wang. All rights reserved.
//

#import "FWSwipePlayerNavLayer.h"
#import "FWPlayerColorUtil.h"
@interface FWSwipePlayerNavLayer()
{
    FWPlayerColorUtil *colorUtil;
    FWSwipePlayerConfig *config;
    UIImageView *navView;
    UIButton *doneBtn;
    UIButton *settingBtn;
    UILabel *titleLabel;
}

@end

@implementation FWSwipePlayerNavLayer

- (id)initLayerAttachTo:(UIView *)view config:(FWSwipePlayerConfig*)configuration
{
    self = [super initLayerAttachTo:view];
    if(self)
    {
        colorUtil = [[FWPlayerColorUtil alloc]init];
        config = configuration;
        [self configNavView];
    }
    
    return self;
}

-(void)configNavView
{
    navView = [[UIImageView alloc] init];
    navView.userInteractionEnabled = YES;
    [colorUtil setGradientBlackToWhiteColor:navView];
    
    doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(8, 8, 22, 22);
    [doneBtn setTitle:@"X" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    if(!config.draggable)
        [navView addSubview:doneBtn];
    
    settingBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
    [settingBtn addTarget:self action:@selector(settingBtnOnClick:)forControlEvents:UIControlEventTouchUpInside];
    [settingBtn setImage:[UIImage imageNamed: @"btn_player_setting"] forState:UIControlStateNormal];
    [navView addSubview:settingBtn];
    
    self.lockScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
    
    [self.lockScreenBtn addTarget:self action:@selector(lockScreenBtnOnClick:)forControlEvents:UIControlEventTouchUpInside];
    [self.lockScreenBtn setImage:[UIImage imageNamed: @"plugin_fullscreen_bottom_lock_btn_normal"] forState:UIControlStateNormal];
    [self.lockScreenBtn setHidden:YES];
    [navView addSubview:self.lockScreenBtn];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.text = config.currentVideoTitle;
    [titleLabel setHidden:YES];
    [navView addSubview:titleLabel];
    
    [self.layerView addSubview:navView];
}

-(void)updateFrame:(CGRect)frame
{
    [super updateFrame:frame];
    titleLabel.frame =  CGRectMake(30, 12, frame.size.width - 140, 16);
    navView.frame = CGRectMake(0, 20, frame.size.width, frame.size.height-20);
    settingBtn.frame = CGRectMake(frame.size.width - 22 - 8, 8, 22, 22);
    self.lockScreenBtn.frame = CGRectMake(settingBtn.frame.origin.x  - 22 - 16, 2, 74 / 2, 92 / 2);
}

- (void)orientationChange:(UIDeviceOrientation)orientation
{
    if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        [titleLabel setHidden:NO];
        [self.lockScreenBtn setHidden:NO];
    }
    else if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        [self.lockScreenBtn setHidden:YES];
        [titleLabel setHidden:YES];
    }
}

-(void)doneBtnOnClick:(id)sender
{
    if(self.delegate)
        if([self.delegate respondsToSelector:@selector(doneBtnOnClick:)])
            [self.delegate doneBtnOnClick:sender];
}

-(void)settingBtnOnClick:(id)sender
{
    if(self.delegate)
        if([self.delegate respondsToSelector:@selector(settingBtnOnClick:)])
            [self.delegate settingBtnOnClick:sender];
}

-(void)lockScreenBtnOnClick:(id)sender
{
    if(self.delegate)
        if([self.delegate respondsToSelector:@selector(lockScreenBtnOnClick:)])
            [self.delegate lockScreenBtnOnClick:sender];
}

@end
