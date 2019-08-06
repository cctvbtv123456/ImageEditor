//
//  ImageToolBase.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageEditorChildVC.h"

static const CGFloat kImageToolAnimationDuration = 0.3;
static const CGFloat kImageToolBaseFadeoutDuration = 0.2;

static NSString *kImageToolDrawLineWidthKey = @"drawLineWidth";
static NSString *kImageToolDrawLineColorKey = @"drawLineColor";

static NSString *kImageToolTextColorKey = @"textColor";
static NSString *kImageToolTextFontKey = @"textFont";

NS_ASSUME_NONNULL_BEGIN

@interface ImageToolBase : NSObject
@property (nonatomic, weak) ImageEditorChildVC *editorVC;
@property (nonatomic, strong) NSDictionary *option;
/** 是否使用过该工具,即图片产生了编辑操作 */
@property (nonatomic, assign) BOOL produceChanges;
- (instancetype)initWithImageEditor:(ImageEditorVC *)editorVC
                             option:(NSDictionary *)option;
- (void)initialize;
- (void)setup;
- (void)cleanup;
- (void)resetRect:(CGRect)rect;
- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation;
@end

NS_ASSUME_NONNULL_END
