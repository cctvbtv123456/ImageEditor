//
//  ColorToolBar.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "EditorToolBar.h"

NS_ASSUME_NONNULL_BEGIN

@class ColorToolBar;

typedef NS_ENUM(NSInteger, ColorToolBarType) {
    ColorToolBarTypeColor =0,
    ColorToolBarTypeText
};

typedef NS_ENUM(NSUInteger, ColorToolBarEvent) {
    ColorToolBarEventSelectColor = 0,
    ColorToolBarEventUndo,
    ColorToolBarEventChangeBgColor
};

@protocol ColorToolBarDelegate<NSObject>

@optional

- (void)colorToolBar:(ColorToolBar *)toolBar event:(ColorToolBarEvent)event;

@end

@interface ColorToolBar : EditorToolBar

@property (nonatomic, strong) UIColor *currentColor;

@property (nonatomic, assign) BOOL canUndo;
/** 是否可以改变文字颜色 */
@property (nonatomic, assign, getter=isChangeBgColor) BOOL changeBgColor;

@property (nonatomic, weak) id<ColorToolBarDelegate> delegate;

- (instancetype)initWithType:(ColorToolBarType)type;

- (BOOL)isWhiteColor;

@end

NS_ASSUME_NONNULL_END
