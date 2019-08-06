//
//  ImageEditorVC.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ImageEditorVC;

@protocol ImageEditorDelegate <NSObject>
@optional
- (void)imageEditor:(ImageEditorVC *)editor didFinishEdittingWithImage:(UIImage *)image;
- (void)imageEditorDidCancel;
@end

@protocol ImageEditorDataSource <NSObject>

@optional
- (UIColor *)imageEditorDefaultColor;
- (CGFloat)imageEditorDrawPathWidth;
- (UIFont *)imageEditorTextFont;

@end

typedef NS_ENUM(NSInteger, ImageEditorMode) {
    
    ImageEditorModeNone =-1,
    ImageEditorModeDraw,
    ImageEditorModeText,
};

@interface ImageEditorVC : UIViewController
@property (nonatomic, weak) id<ImageEditorDelegate> delegate;
@property (nonatomic, weak) id<ImageEditorDataSource> dataSource;
@property (nonatomic, assign) ImageEditorMode editorMode;
/* 是否使用过该工具,即图片产生了编辑操作 */
@property (nonatomic, assign) BOOL produceChanges;

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image
                     delegate:(id<ImageEditorDelegate>)delegate
                   dataSource:(id<ImageEditorDataSource>)dataSource;
- (void)dismiss;
@end






NS_ASSUME_NONNULL_END
