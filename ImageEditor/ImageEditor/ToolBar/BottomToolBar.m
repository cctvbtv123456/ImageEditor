//
//  BottomToolBar.m
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "BottomToolBar.h"
#import "QXEditorButton.h"
#import "ImageEditorHeader.h"

@interface BottomToolBar()

@property (nonatomic, strong) UIImageView *maskImageView;

@property (nonatomic, strong) QXEditorButton *drawButton;

@property (nonatomic, strong) QXEditorButton *textButton;

@property (nonatomic, strong) UIView *deleteContainerView;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIButton *deleteDescBtn;

@property (nonatomic, assign) BottomToolType type;

@end

@implementation BottomToolBar

- (instancetype)initWithType:(BottomToolType)type{
    
    if (self == [super init]) {
        self.type = type;
        switch (type) {
            case BottomToolTypeEditor:
                [self configEditorUI];
                break;
            case BottomToolTypeDelete:
                [self configDeleteUI];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)configEditorUI{
    [self addSubview:self.maskImageView];
    [self addSubview:self.drawButton];
    [self addSubview:self.textButton];
    
    
    [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    NSMutableArray *editorItems = [NSMutableArray array];
    [editorItems addObject:self.drawButton];
    [editorItems addObject:self.textButton];
    [editorItems mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:28*kScale leadSpacing:48*kScale tailSpacing:48*kScale];
    [editorItems mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-20*kScale);
        }else{
            make.bottom.equalTo(@(-20*kScale));
        }
        make.height.equalTo(@(28*kScale));
    }];
    self.tempEditorItem = editorItems.firstObject;
}

- (void)configDeleteUI{
    [self addSubview:self.maskImageView];
    [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.deleteContainerView = [[UIView alloc] init];
    [self addSubview:self.deleteContainerView];
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteBtn setImage:[UIImage ps_imageNamed:@"btn_delete_normal"] forState:UIControlStateNormal];
    [self.deleteBtn setImage:[UIImage ps_imageNamed:@"btn_delete_selected"] forState:UIControlStateSelected];
    [self.deleteContainerView addSubview:self.deleteBtn];
    
    self.deleteDescBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteDescBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.deleteDescBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.deleteDescBtn setTitle:@"拖动到此处删除" forState:UIControlStateNormal];
    [self.deleteDescBtn setTitle:@"松手即可删除" forState:UIControlStateSelected];
    [self.deleteContainerView addSubview:self.deleteDescBtn];
    
    [self.deleteContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.deleteContainerView);
        make.bottom.equalTo(self.deleteDescBtn.mas_top).offset(-12*kScale);
    }];
    
    [self.deleteDescBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.deleteBtn);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-20*kScale);
        } else {
            make.bottom.equalTo(@(-20*kScale));
        }
    }];
}

- (void)setDeleteState:(BottomToolDeleteState)deleteState{
    _deleteState = deleteState;
    if (deleteState == BottomToolDeleteStateDid) {
        self.deleteBtn.selected = YES;
        self.deleteDescBtn.selected = YES;
    }else{
        self.deleteBtn.selected = NO;
        self.deleteDescBtn.selected = NO;
    }
}

- (void)buttonDidClickSender:(UIButton *)btn{
    
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]] && (button != btn)) {
            button.selected = NO;
        }
    }
    
    BottomToolBarEvent event;
    if (btn == self.drawButton) {
        event = BottomToolBarEventDraw;
    }else if (btn == self.textButton){
        event = BottomToolBarEventText;
    }else{
        event = BottomToolBarEventNone;
    }
    
    btn.selected = !btn.isSelected;
    self.editor = btn.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomToolBar:didClickEvent:)]) {
        [self.delegate bottomToolBar:self didClickEvent:event];
    }
}

- (void)reset{
    self.drawButton.selected = NO;
    self.textButton.selected = NO;
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation{
    self.wilShow = show;
    [UIView animateWithDuration:(animation ? EditorToolBarAnimationDuration : 0) animations:^{
        if (show) {
            self.transform = CGAffineTransformIdentity;
        }else{
            if (self.type == BottomToolTypeEditor) {
                self.transform = CGAffineTransformMakeTranslation(0, BottomToolBarHeight);
            }else{
                self.transform = CGAffineTransformMakeTranslation(0, BottomToolDeleteBarHeight);
            }
        }
    }];
}

- (UIImageView *)maskImageView {
    
    return LAZY_LOAD(_maskImageView, ({
        _maskImageView = [[UIImageView alloc] initWithImage:[UIImage ps_imageNamed:@"icon_mask_bottom"]];
        _maskImageView;
    }));
}

- (QXEditorButton *)drawButton{
    
    return LAZY_LOAD(_drawButton, ({
        _drawButton = [[QXEditorButton alloc] init];
        [_drawButton setImage:[UIImage ps_imageNamed:@"btn_brush_normal"]
                     forState:UIControlStateNormal];
        [_drawButton setImage:[UIImage ps_imageNamed:@"btn_brush_selected"]
                     forState:UIControlStateSelected];
        [_drawButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
        _drawButton;
    }));
}

- (QXEditorButton *)textButton{
    
    return LAZY_LOAD(_textButton, ({
        _textButton = [[QXEditorButton alloc] init];
        [_textButton setImage:[UIImage ps_imageNamed:@"btn_text_normal"]
                     forState:UIControlStateNormal];
        [_textButton setImage:[UIImage ps_imageNamed:@"btn_text_selected"]
                     forState:UIControlStateSelected];
        [_textButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
        _textButton;
    }));
}



@end
