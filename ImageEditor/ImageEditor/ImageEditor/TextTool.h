//
//  TextTool.h
//  ImageEditor
//
//  Created by Justin on 2019/8/2.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ImageToolBase.h"

NS_ASSUME_NONNULL_BEGIN

@class ZPTextView;

@interface TextTool : ImageToolBase

@property (nonatomic, strong) ZPTextView *textView;
/** 再次编辑textviewitem */
@property (nonatomic, assign) BOOL isEditAgain;
/** 关闭页面 */
@property (nonatomic, copy) void(^dissmissCallBack) (NSString *currentText);
/** 再次编辑回调 */
@property (nonatomic, copy) void(^editAgainCallBack) (NSString *text, NSDictionary *atts);

@end




@interface ZPTextView: UIView

@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, strong) UITextView *inputView;

@property (nonatomic, strong) NSDictionary *atts; //预设属性

@property (nonatomic, copy) void(^dissMissBlock) (NSString *text, NSDictionary *atts, BOOL use);

@end

NS_ASSUME_NONNULL_END
