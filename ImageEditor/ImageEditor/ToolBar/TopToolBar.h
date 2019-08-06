//
//  TopToolBar.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "EditorToolBar.h"

NS_ASSUME_NONNULL_BEGIN

@class TopToolBar;

typedef NS_ENUM(NSUInteger, TopToolBarType) {
    TopToolBarTypeCancelAndDoneText = 0,
    TopToolBarTypeCancelAndDoneIcon,
};

typedef NS_ENUM(NSUInteger, TopToolBarEvent) {
    TopToolBarEventCancel = 0,
    TopToolBarEventDone,
};

@protocol TopToolBarDelegate<NSObject>
- (void)topToolBar:(TopToolBar *)toolBar event:(TopToolBarEvent)event;
@end

@interface TopToolBar : EditorToolBar

@property (nonatomic, assign, getter=isShow) BOOL show;

@property (nonatomic, weak) id<TopToolBarDelegate>delegate;

@property (nonatomic, assign) TopToolBarType type;

- (instancetype)initWithType:(TopToolBarType)type;

@end

NS_ASSUME_NONNULL_END
