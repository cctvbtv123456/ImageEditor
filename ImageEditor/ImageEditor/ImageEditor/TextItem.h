//
//  TextItem.h
//  ImageEditor
//
//  Created by Justin on 2019/8/4.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextTool.h"

NS_ASSUME_NONNULL_BEGIN

@class TextItem, TextTool;

@protocol TextItemDelegate <NSObject>

@optional

- (BOOL)textItemRestrictedPanAreasWithTextItem:(TextItem *)item;

- (void)textItem:(TextItem *)item translationGesture:(UIPanGestureRecognizer *)gesture activation:(BOOL)activation;

- (void)textItemDidClickWithItem:(TextItem *)item;

@end


@interface TextItem : UIView
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;

/** item处于激活状态 */
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, weak) id<TextItemDelegate> delegate;

+ (void)setActiveTextView:(TextItem *)view;
+ (void)setInactiveTextView:(TextItem *)view;

- (instancetype)initWithTool:(TextTool *)tool
                        text:(NSString *)text
                        font:(UIFont *)font;
- (void)setScale:(CGFloat)scale;
- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight;
- (void)remove;

@end

NS_ASSUME_NONNULL_END
