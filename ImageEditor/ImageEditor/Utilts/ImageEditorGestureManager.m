//
//  ImageEditorGestureManager.m
//  ImageEditor
//
//  Created by Justin on 2019/8/4.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ImageEditorGestureManager.h"
#import "TextItem.h"

@interface ImageEditorGestureManager()

@property (nonatomic, strong) NSHashTable *gestureTable;

@end

@implementation ImageEditorGestureManager

+ (instancetype)instance{
    
    static ImageEditorGestureManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ImageEditorGestureManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    if (self == [super init]) {
        _gestureTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsStrongMemory capacity:2];
    }
    return self;
}

#pragma mark - UIGestureRecognizerDelegate
// 同时识别两个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([gestureRecognizer.view isKindOfClass:[TextItem class]] && [otherGestureRecognizer.view isKindOfClass:[TextItem class]]) {
        NSArray *gesture = @[gestureRecognizer, otherGestureRecognizer];
        for (UIGestureRecognizer *ges in gesture) {
            if ([ges isKindOfClass:[UITapGestureRecognizer class]]) {
                return NO;
            }
        }
        return YES;
    }else{
        return NO;
    }
}

// 是否允许开始触发手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

// 是否允许接收手指的触摸点
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![self.gestureTable containsObject:gestureRecognizer]) {
        [self.gestureTable addObject:gestureRecognizer];
        if (self.gestureTable.count >= 2) {
            UIPanGestureRecognizer *textToolPan = nil;
            UIPanGestureRecognizer *drawToolPan = nil;
            
            for (UIPanGestureRecognizer *pan in self.gestureTable) {
                if ([pan.view isKindOfClass:[TextItem class]]) {
                    textToolPan = pan;
                }
                if ([pan.view isKindOfClass:[UIImageView class]]) {
                    drawToolPan = pan;
                }
            }
            if (textToolPan && drawToolPan) {
                [drawToolPan requireGestureRecognizerToFail:textToolPan];
            }
        }
    }
    return YES;
}

@end
