//
//  ColorFullButton.h
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QXEditorButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColorFullButton : UIButton

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) BOOL isUse;

@property (nonatomic, strong) UIColor *color;

@end

NS_ASSUME_NONNULL_END
