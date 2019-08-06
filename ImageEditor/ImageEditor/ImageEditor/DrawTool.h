//
//  DrewTool.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ImageToolBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DrawTool : ImageToolBase
{
    @public UIImageView *_drewingView;
}
@end



@interface DrewPath : UIBezierPath

@property (nonatomic, strong) CAShapeLayer *shape;
/** 画笔颜色 */
@property (nonatomic, strong) UIColor *pathColor;

+ (instancetype)pathToPoint:(CGPoint)beginPoint
                  pathWidth:(CGFloat)pathWidth;

/** 画 */
- (void)pathLineToPoint:(CGPoint)movePoint;

/** 绘制 */
- (void)drewPath;

@end

NS_ASSUME_NONNULL_END
