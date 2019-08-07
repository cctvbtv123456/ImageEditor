//
//  ImageEditorHeader.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#ifndef ImageEditorHeader_h
#define ImageEditorHeader_h

#define ZP_Screen_W                [UIScreen mainScreen].bounds.size.width
#define ZP_kScale                  ZP_Screen_W/375.0
#define ZP_Screen_H                [UIScreen mainScreen].bounds.size.height
#define ZP_kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define ZP_kNavBarHeight 44.0
#define ZP_kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define ZP_kTopHeight (ZP_kStatusBarHeight + ZP_kNavBarHeight)

#define ZP_TopToolBarHeight             80*ZP_kScale
#define ZP_BottomToolBarHeight          120*ZP_kScale
#define ZP_BottomToolDeleteBarHeight    80*ZP_kScale
#define ZP_TextColorToolBarHeight 48*ZP_kScale
#define ZP_DrawColorToolBarHeight 50*ZP_kScale


#define LAZY_LOAD(object, assignment) (object = object ?: assignment)
#define ZP_UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


/** 字体 */
#define ZP_Font_Bold(font)         [UIFont fontWithName:@"PingFangSC-Medium" size:font]?[UIFont fontWithName:@"PingFangSC-Medium" size:font]:[UIFont systemFontOfSize:font]
#define ZP_Font_Medium(font)       [UIFont fontWithName:@"PingFangSC-Medium" size:font]?[UIFont fontWithName:@"PingFangSC-Regular" size:font]:[UIFont systemFontOfSize:font]
#define ZP_Font_Regular(font)      [UIFont fontWithName:@"PingFangSC-Regular" size:font]?[UIFont fontWithName:@"PingFangSC-Light" size:font]:[UIFont systemFontOfSize:font]

#endif /* ImageEditorHeader_h */
