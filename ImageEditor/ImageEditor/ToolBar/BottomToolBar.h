//
//  BottomToolBar.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "EditorToolBar.h"

NS_ASSUME_NONNULL_BEGIN

@class EditorToolBar, BottomToolBar;

typedef NS_ENUM(NSUInteger, BottomToolType) {
    
    BottomToolTypeEditor =0,    /**< 编辑样式  */
    BottomToolTypeDelete,   /**< 拖动删除标样式  */
};

typedef NS_ENUM(NSUInteger, BottomToolDeleteState) {
    
    BottomToolDeleteStateNormal = 0,/**< 默认样式，显示删除按钮  */
    BottomToolDeleteStateWill,     /**< 拖拽到删除区域，将要删除  */
    BottomToolDeleteStateDid,     /**< 拖拽到删除区域释放，删除 */
};

typedef NS_ENUM(NSInteger, BottomToolBarEvent) {
    
    BottomToolBarEventDraw = 0,
    BottomToolBarEventText,
    BottomToolBarEventNone,
};


@protocol BottomToolBarDelegate<NSObject>

- (void)bottomToolBar:(BottomToolBar *)toolBar
        didClickEvent:(BottomToolBarEvent)event;

@end

@interface BottomToolBar : EditorToolBar

@property (nonatomic, assign, getter=isEditor) BOOL editor;

@property (nonatomic, assign, getter=isWilShow) BOOL wilShow;
/// 用于参照布局
@property (nonatomic, strong) UIView *tempEditorItem;
/// PSBottomToolTypeDelete模式下删除的样式
@property (nonatomic, assign) BottomToolDeleteState deleteState;

@property (nonatomic, weak) id<BottomToolBarDelegate> delegate;

- (instancetype)initWithType:(BottomToolType)type;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
