//
//  ImageEditorChildVC.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ImageEditorVC.h"
#import "BottomToolBar.h"
#import "TopToolBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageEditorChildVC : ImageEditorVC
/** 缩放容器 */
@property (nonatomic, strong) UIScrollView *scrollView;
/** 最底层负责显示的照片 */
@property (nonatomic, strong) UIImageView *imageView;
/** 顶部功能控件 */
@property (nonatomic, strong, readwrite) TopToolBar *topToolBar;
/** 底部功能控件 */
@property (nonatomic, strong, readwrite) BottomToolBar *bottomToolBar;

@property (nonatomic, copy) void(^scrollViewDidZoomBlock) (CGFloat zoomScale);

- (void)buildClipImageCallBack:(void(^)(UIImage *clipedImage))callBack;

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
