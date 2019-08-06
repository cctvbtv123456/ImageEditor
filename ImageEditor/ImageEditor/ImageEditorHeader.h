//
//  ImageEditorHeader.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#ifndef ImageEditorHeader_h
#define ImageEditorHeader_h

#define Screen_W                [UIScreen mainScreen].bounds.size.width
#define kScale                  Screen_W/375.0
#define Screen_H                [UIScreen mainScreen].bounds.size.height
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)

#define TopToolBarHeight             80*kScale
#define BottomToolBarHeight          120*kScale
#define BottomToolDeleteBarHeight    80*kScale
#define TextColorToolBarHeight 48*kScale
#define DrawColorToolBarHeight 50*kScale


/** 字体 */
#define Font_Bold(font)         [UIFont fontWithName:@"PingFangSC-Medium" size:font]?[UIFont fontWithName:@"PingFangSC-Medium" size:font]:[UIFont systemFontOfSize:font]
#define Font_Medium(font)       [UIFont fontWithName:@"PingFangSC-Medium" size:font]?[UIFont fontWithName:@"PingFangSC-Regular" size:font]:[UIFont systemFontOfSize:font]
#define Font_Regular(font)      [UIFont fontWithName:@"PingFangSC-Regular" size:font]?[UIFont fontWithName:@"PingFangSC-Light" size:font]:[UIFont systemFontOfSize:font]

#endif /* ImageEditorHeader_h */
