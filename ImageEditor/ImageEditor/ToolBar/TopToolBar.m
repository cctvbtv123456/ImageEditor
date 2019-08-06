//
//  TopToolBar.m
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "TopToolBar.h"

@interface TopToolBar()
@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *doneButton;
@end

@implementation TopToolBar

- (instancetype)initWithType:(TopToolBarType)type{
    if (self == [super init]) {
        _type = type;
        switch (type) {
            case TopToolBarTypeCancelAndDoneText:
                [self configCancelAndDoneTextUI];
                break;
            case TopToolBarTypeCancelAndDoneIcon:
                [self configCancelAndDoneIconUI];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)buttonDidClickSender:(UIButton *)btn {
    TopToolBarEvent event = (btn == self.backButton ? TopToolBarEventCancel:TopToolBarEventDone);
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolBar:event:)]) {
        [self.delegate topToolBar:self event:event];
    }
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation{
    [UIView animateWithDuration:(animation ? 0.2 : 0) animations:^{
        if (show) {
            self.transform = CGAffineTransformIdentity;
        }else{
            self.transform = CGAffineTransformMakeTranslation(0, -TopToolBarHeight);
        }
    } completion:^(BOOL finished) {
        self.show = show;
    }];
}

- (void)configCancelAndDoneTextUI{
    
    [self addSubview:self.maskImageView];
    [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.backButton.titleLabel.font = Font_Medium(18*kScale);
    [self.backButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:self.backButton];
    
    [self.doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:self.doneButton];

    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(56*kScale));
        make.height.equalTo(@(32*kScale));
        make.left.equalTo(@(20*kScale));
     
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(30*kScale);
        } else {
            make.top.equalTo(@(30*kScale));
        }
    }];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(32*kScale));
        make.width.equalTo(@(56*kScale));
        make.right.equalTo(@(-20*kScale));
        make.centerY.equalTo(self.backButton);
    }];
}

- (void)configCancelAndDoneIconUI{
    self.backButton.backgroundColor = UIColorFromRGB(0x5d7ef1);
    [self.backButton setImage:[UIImage ps_imageNamed:@"btn_cancel"]
                     forState:UIControlStateNormal];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self addSubview:self.backButton];
    
    [self.doneButton setImage:[UIImage ps_imageNamed:@"btn_done"]
                     forState:UIControlStateNormal];
    [self addSubview:self.doneButton];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(50*kScale));
        make.height.equalTo(@(36*kScale));
        make.left.equalTo(@(20*kScale));
        make.centerY.equalTo(self);
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(36*kScale));
        make.width.equalTo(@(50*kScale));
        make.right.equalTo(@(-20*kScale));
        make.centerY.equalTo(self.backButton);
    }];
}

- (UIImageView *)maskImageView {
    return LAZY_LOAD(_maskImageView, ({
        _maskImageView = [[UIImageView alloc] initWithImage:[UIImage ps_imageNamed:@"icon_mask_top"]];
        _maskImageView;
    }));
}

- (UIButton *)backButton {
    return LAZY_LOAD(_backButton, ({
        _backButton = [[UIButton alloc] init];
        _backButton.titleLabel.font = Font_Regular(16*kScale);
        [_backButton setFrame:CGRectMake(0, 0, 50*kScale, 36*kScale)];
        _backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [_backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_backButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
        _backButton;
    }));
}

- (UIButton *)doneButton {
    return LAZY_LOAD(_doneButton, ({
        _doneButton = [[UIButton alloc] init];
        _doneButton.backgroundColor = UIColorFromRGB(0x5d7ef1);
        _doneButton.layer.cornerRadius = 5*kScale;
        _doneButton.clipsToBounds = YES;
        _doneButton.titleLabel.font = Font_Regular(16*kScale);
        [_doneButton setFrame:CGRectMake(0, 0, 48*kScale, 36*kScale)];
//        _doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//        [_doneButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_doneButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
        _doneButton;
    }));
}


@end
