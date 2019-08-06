//
//  ColorToolBar.m
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//


#define kColorFullButtonSize CGSizeMake(26*kScale, 26*kScale)

#import "ColorToolBar.h"
#import "ColorFullButton.h"
#import "QXEditorButton.h"

@interface ColorToolBar()
@property (nonatomic, strong) ColorFullButton *redBtn;
@property (nonatomic, strong) ColorFullButton *blackBtn;
@property (nonatomic, strong) ColorFullButton *whiteBtn;
@property (nonatomic, strong) ColorFullButton *yellowBtn;
@property (nonatomic, strong) ColorFullButton *greenBtn;
@property (nonatomic, strong) ColorFullButton *lightBuleBtn;
@property (nonatomic, strong) ColorFullButton *blueBtn;

@property (nonatomic, strong) UIView *colorFullBtnViews;
@property (nonatomic, strong) UIButton *unDoBtn;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIButton *changeBgColorBtn;
@end

@implementation ColorToolBar

- (instancetype)initWithType:(ColorToolBarType)type{
    if (self == [super init]) {
        switch (type) {
            case ColorToolBarTypeColor:
                [self configDrawUI];
                break;
            case ColorToolBarTypeText:
                [self configTextUI];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)configTextUI{
    self.changeBgColorBtn = [QXEditorButton buttonWithType:UIButtonTypeCustom];
//    self.changeBgColorBtn.backgroundColor = [UIColor yellowColor];
    [self.changeBgColorBtn setImage:[UIImage ps_imageNamed:@"btn_changeTextBgColor_normal"] forState:UIControlStateNormal];
    [self.changeBgColorBtn setImage:[UIImage ps_imageNamed:@"btn_changeTextBgColor_selected"]
                          forState:UIControlStateSelected];
    [self.changeBgColorBtn addTarget:self action:@selector(changeBgColorButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.changeBgColorBtn];
    
    self.colorFullBtnViews = [[UIView alloc] init];
//    self.colorFullBtnViews.backgroundColor = [UIColor yellowColor];
    [self addSubview:self.colorFullBtnViews];
    
    [self.colorFullBtnViews addSubview:self.whiteBtn];
    [self.colorFullBtnViews addSubview:self.blackBtn];
    [self.colorFullBtnViews addSubview:self.redBtn];
    [self.colorFullBtnViews addSubview:self.yellowBtn];
    [self.colorFullBtnViews addSubview:self.greenBtn];
    [self.colorFullBtnViews addSubview:self.lightBuleBtn];
    [self.colorFullBtnViews addSubview:self.blueBtn];
    
    // 使用手势识别，关闭自带交互
    for (ColorFullButton *button in self.colorFullBtnViews.subviews) {
        button.userInteractionEnabled = NO;
    }
    
    [_changeBgColorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(@(17*kScale));
        make.width.equalTo(@(kColorFullButtonSize.width));
        make.height.equalTo(@(kColorFullButtonSize.height));
    }];
    
    [_colorFullBtnViews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.changeBgColorBtn);
        make.left.equalTo(self.changeBgColorBtn.mas_right).offset(20*kScale);
        make.height.equalTo(@(kColorFullButtonSize.height));
        make.right.equalTo(@(-17*kScale));
    }];
    
    [_colorFullBtnViews.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                                             withFixedItemLength:kColorFullButtonSize.width
                                                     leadSpacing:0
                                                     tailSpacing:0];
    
    [_colorFullBtnViews.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->_colorFullBtnViews);
        make.height.equalTo(@(kColorFullButtonSize.height));
    }];
    
    // 设置默认选中颜色
    self.whiteBtn.isUse = YES;
    self.currentColor = self.whiteBtn.color;
}

- (void)configDrawUI{
    self.colorFullBtnViews = [[UIView alloc] init];
    [self addSubview:self.colorFullBtnViews];
    
    [self.colorFullBtnViews addSubview:self.redBtn];
    [self.colorFullBtnViews addSubview:self.blackBtn];
    [self.colorFullBtnViews addSubview:self.whiteBtn];
    [self.colorFullBtnViews addSubview:self.yellowBtn];
    [self.colorFullBtnViews addSubview:self.greenBtn];
    [self.colorFullBtnViews addSubview:self.lightBuleBtn];
    [self.colorFullBtnViews addSubview:self.blueBtn];
    // 使用手势识别，关闭自带交互
    for (ColorFullButton *button in self.colorFullBtnViews.subviews) {
        button.userInteractionEnabled = NO;
    }
    
    self.unDoBtn = [QXEditorButton buttonWithType:UIButtonTypeSystem];
    [self.unDoBtn setImage:[UIImage ps_imageNamed:@"btn_revocation_normal"]
                 forState:UIControlStateNormal];
    [self.unDoBtn setImage:[UIImage ps_imageNamed:@"btn_revocation_disabled"]
                 forState:UIControlStateDisabled];
    self.unDoBtn.enabled = NO;
    [self.unDoBtn addTarget:self action:@selector(undoButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.unDoBtn];
    
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    [self addSubview:_bottomLineView];
    
    [self.unDoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-25*kScale));
        make.bottom.equalTo(@(-30*kScale));
        make.size.equalTo(@(23*kScale));
    }];
    
    [self.colorFullBtnViews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15*kScale));
        make.height.equalTo(@(kColorFullButtonSize.height));
        make.right.equalTo(self.unDoBtn.mas_left).offset(-5*kScale);
        make.centerY.equalTo(self.unDoBtn);
    }];
    
    [self.colorFullBtnViews.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                                             withFixedItemLength:kColorFullButtonSize.width
                                                     leadSpacing:15*kScale
                                                     tailSpacing:15*kScale];
    
    [self.colorFullBtnViews.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.colorFullBtnViews);
        make.height.equalTo(@(kColorFullButtonSize.height));
    }];
    
    [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15*kScale));
        make.right.equalTo(@(-15*kScale));
        make.bottom.equalTo(self);
        make.height.equalTo(@(0.5*kScale));
    }];
    
    // 设置默认选中颜色
    self.redBtn.isUse = YES;
    self.currentColor = self.redBtn.color;
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation{
    [UIView animateWithDuration:(animation ? 0.15 : 0) animations:^{
        self.alpha = (show ? 1.0f : 0.0f);
    }];
}

- (void)setCanUndo:(BOOL)canUndo{
    _canUndo = canUndo;
    self.unDoBtn.enabled = canUndo;
}

- (BOOL)isWhiteColor{
    return CGColorEqualToColor(self.currentColor.CGColor, self.whiteBtn.color.CGColor);
}

- (void)setCurrentColor:(UIColor *)currentColor{
    _currentColor = currentColor;
    for (ColorFullButton *btn in self.colorFullBtnViews.subviews) {
        btn.isUse = CGColorEqualToColor(btn.color.CGColor, currentColor.CGColor);
    }
}

- (void)undoButtonDidClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorToolBar:event:)]) {
        [self.delegate colorToolBar:self event:ColorToolBarEventUndo];
    }
}
- (void)changeBgColorButtonDidClick{
    
    self.changeBgColorBtn.selected = !self.changeBgColorBtn.selected;
    self.changeBgColor = self.changeBgColorBtn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorToolBar:event:)]) {
        [self.delegate colorToolBar:self event:ColorToolBarEventChangeBgColor];
    }
}

- (void)colorFullButtonDidClick:(ColorFullButton *)sender{
    for (ColorFullButton *button in self.colorFullBtnViews.subviews) {
        if (button == sender) {
            button.isUse = YES;
            self.currentColor = sender.color;
        }else{
            button.isUse = NO;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorToolBar:event:)]) {
        [self.delegate colorToolBar:self event:ColorToolBarEventSelectColor];
    }
}

#pragma mark - 手动手势识别，兼容滑动选择
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    for (ColorFullButton *button in self.colorFullBtnViews.subviews) {
        CGRect rect = [button convertRect:button.bounds toView:self];
        if (CGRectContainsPoint(rect, touchPoint) && button.isUse == NO) {
            [self colorFullButtonDidClick:button];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    for (ColorFullButton *button in self.colorFullBtnViews.subviews) {
        CGRect rect = [button convertRect:button.bounds toView:self];
        if (CGRectContainsPoint(rect, touchPoint) && button.isUse == NO) {
            [self colorFullButtonDidClick:button];
        }
    }
}

- (ColorFullButton *)blueBtn {
    return LAZY_LOAD(_blueBtn, ({
        
        _blueBtn = [[ColorFullButton alloc] initWithFrame:
                       CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
        _blueBtn.radius = 8*kScale;
        _blueBtn.color = UIColorFromRGB(0x8c06ff);
        _blueBtn;
    }));
}

- (ColorFullButton *)lightBuleBtn {
    return LAZY_LOAD(_lightBuleBtn, ({
        _lightBuleBtn = [[ColorFullButton alloc] initWithFrame:
                            CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
        _lightBuleBtn.radius = 8*kScale;
        _lightBuleBtn.color = UIColorFromRGB(0x199bff);
        _lightBuleBtn;
    }));
}

- (ColorFullButton *)greenBtn {
    return LAZY_LOAD(_greenBtn, ({
        _greenBtn = [[ColorFullButton alloc] initWithFrame:
                        CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
        _greenBtn.radius = 8*kScale;
        _greenBtn.color = UIColorFromRGB(0x14e213);
        _greenBtn;
    }));
}

- (ColorFullButton *)yellowBtn {
    return LAZY_LOAD(_yellowBtn, ({
        _yellowBtn = [[ColorFullButton alloc] initWithFrame:
                         CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
        _yellowBtn.radius = 8*kScale;
        _yellowBtn.color = UIColorFromRGB(0xfbf60f);
        _yellowBtn;
    }));
}

- (ColorFullButton *)whiteBtn {
    return LAZY_LOAD(_whiteBtn, ({
        _whiteBtn = [[ColorFullButton alloc] initWithFrame:
                        CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
        _whiteBtn.radius = 8*kScale;
        _whiteBtn.color = UIColorFromRGB(0xf9f9f9);
        _whiteBtn;
    }));
}

- (ColorFullButton *)blackBtn {
    return LAZY_LOAD(_blackBtn, ({
        _blackBtn = [[ColorFullButton alloc] initWithFrame:
                        CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
        _blackBtn.radius = 8*kScale;
        _blackBtn.color = UIColorFromRGB(0x26252a);
        _blackBtn;
    }));
}

- (ColorFullButton *)redBtn {
    return LAZY_LOAD(_redBtn, ({
        _redBtn = [[ColorFullButton alloc] initWithFrame:
                      CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
        _redBtn.radius = 8*kScale;
        _redBtn.color = UIColorFromRGB(0xff1d12);
        _redBtn;
    }));
}


@end
