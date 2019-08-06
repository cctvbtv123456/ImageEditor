//
//  EditorToolBar.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static const CGFloat EditorToolBarAnimationDuration = 0.2;

@interface EditorToolBar : UIView

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
