//
//  Header.h
//  DMWeiboClient
//
//  Created by Blank on 12-12-27.
//  Copyright (c) 2012年 戴 立慧. All rights reserved.
//

#ifndef DMWeiboClient_Header_h
#define DMWeiboClient_Header_h

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define APP_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height
#define NAV_HEIGHT 44.0 //默认导航栏高度
#define STATUEBAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height //顶部状态栏高度
#define TABBAR_HEIGHT 49.0 //tab高度
#define VIEW_HEGHT SCREEN_HEIGHT-NAV_HEIGHT-STATUEBAR_HEIGHT//有状态栏和导航栏的view主体部分大小

#define TIMELINE_IMAGE_SIZE 76.0


//自定义nslog 发布时不打印日志
#ifdef DEBUG
#define DebugLog(format,...) NSLog(format,##__VA_ARGS__)
#else
#define DebugLog(format,...)
#endif

#endif
