//
//  TextTool.m
//  ImageEditor
//
//  Created by Justin on 2019/8/2.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "TextTool.h"
#import "TopToolBar.h"
#import "BottomToolBar.h"
#import "ColorToolBar.h"
#import "TextItem.h"
#import "ImageEditorHeader.h"

static const NSInteger kTextMaxLimitNumber = 100;

@interface TextTool()<TextItemDelegate>
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) BottomToolBar *bottomToolBar;
@end

@implementation TextTool

- (void)initialize{
    [super initialize];
}

- (void)resetRect:(CGRect)rect{
    [self.editorVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TextItem class]]) {
            [obj removeFromSuperview];
        }
    }];
    self.produceChanges = NO;
}

- (void)setup {
    
    [super setup];
    
    [self.editorVC.topToolBar setToolBarShow:NO animation:NO];
    [self.editorVC.bottomToolBar setToolBarShow:NO animation:NO];
    
    if (!self.bottomToolBar) {
        self.bottomToolBar = [[BottomToolBar alloc] initWithType:BottomToolTypeDelete];
        [self.bottomToolBar setToolBarShow:NO animation:NO];
        [self.editorVC.view addSubview:self.bottomToolBar];
        [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.editorVC.view);
            make.height.equalTo(@(BottomToolDeleteBarHeight));
        }];
    }
    
    self.textColor = self.option[kImageToolTextColorKey];
    self.textFont = self.option[kImageToolTextFontKey];
    
    // 关闭scrollView自带的缩放手势
    self.editorVC.scrollView.pinchGestureRecognizer.enabled = NO;
    
    __weak typeof(self)weakSelf = self;
    
    self.textView = [[ZPTextView alloc] initWithFrame:self.editorVC.view.bounds];
    self.textView.inputView.textColor = self.textColor;
    self.textView.inputView.font = self.textFont;
    
    TextItem *activeTexItem  = self.activeItem;
    // 点击了激活的item，再次进入编辑模式
    if (activeTexItem && self.isEditAgain) {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        if (activeTexItem.fillColor) {
            [attrs setObject:activeTexItem.fillColor forKey:NSBackgroundColorAttributeName];
        }
        if (activeTexItem.strokeColor) {
            [attrs setObject:activeTexItem.strokeColor forKey:NSForegroundColorAttributeName];
        }
        if (activeTexItem.font) {
            [attrs setObject:activeTexItem.font forKey:NSFontAttributeName];
        }
        self.textView.inputView.text = activeTexItem.text;
        self.textView.atts = attrs;
    }
    
    self.editorVC.scrollViewDidZoomBlock = ^(CGFloat zoomScale) {
        [self.editorVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[TextItem class]]) {
                obj.transform = CGAffineTransformMakeScale(zoomScale, zoomScale);
            }
        }];
    };
    
    self.textView.dissMissBlock = ^(NSString *text, NSDictionary *attrs, BOOL use) {
        
        if (weakSelf.isEditAgain) { // 点击item
            if (weakSelf.editAgainCallBack && use) {
                weakSelf.editAgainCallBack(text, attrs);
            }
            weakSelf.isEditAgain = NO;
        } else {
            if (use) {
                [weakSelf addTextBoardItemWithText:text attrs:attrs];
            }
        }
        // 开启scrollView自带的缩放手势
        weakSelf.editorVC.scrollView.pinchGestureRecognizer.enabled = YES;
        //[weakSelf cleanup];
        if (weakSelf.dissmissCallBack) {
            weakSelf.dissmissCallBack(text);
        }
    };
    if (!self.textView.superview) {
        [self.editorVC.view addSubview:self.textView];
    }
}


- (void)cleanup {
    [super cleanup];
    [self.textView removeFromSuperview];
    [self.bottomToolBar setToolBarShow:NO animation:NO];
    [self.editorVC.topToolBar setToolBarShow:YES animation:YES];
    [self.editorVC.bottomToolBar setToolBarShow:YES animation:YES];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock {
    
}

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation {
    
    [self.bottomToolBar setToolBarShow:!hidden animation:animation];
}

- (void)changeColor:(NSNotification *)notification {
    UIColor *panColor = (UIColor *)notification.object;
    if (panColor && self.textView) {
        [self.textView.inputView setTextColor:panColor];
    }
}

- (void)addTextBoardItemWithText:(NSString *)text
                           attrs:(NSDictionary *)attrs {

    if (!text && !text.length) { return; }

    UIColor *fillColor = attrs[NSBackgroundColorAttributeName];
    UIColor *strokeColor = attrs[NSForegroundColorAttributeName];
    UIFont *font = attrs[NSFontAttributeName];

    TextItem *texItem = [[TextItem alloc] initWithTool:self text:text font:self.textView.inputView.font];

    CGPoint center = self.editorVC.view.center;
    // 修正超长图文字的显示位置
    if (CGRectGetHeight(self.editorVC.imageView.frame) > Screen_H) {
        center.y = self.editorVC.scrollView.contentOffset.y + Screen_H *0.5;
    }

    texItem.delegate = self;
    texItem.borderColor = [UIColor whiteColor];
    texItem.font = font;
    texItem.strokeColor = strokeColor;
    texItem.fillColor = fillColor;
    texItem.text = text;
    texItem.center = center;
    texItem.userInteractionEnabled = YES;
    [self.editorVC.view addSubview:texItem];
    [TextItem setActiveTextView:texItem];
}

- (TextItem *)activeItem {
    __block TextItem *activeItem;
    [self.editorVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TextItem class]]) {
            if (((TextItem *)obj).isActive) {
                activeItem = obj;
                *stop = YES;
            }
        }
    }];
    return activeItem;
}

- (BOOL)produceChanges {
    __block BOOL containsTexItem = NO;
    [self.editorVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TextItem class]]) {
            containsTexItem = YES;
            *stop = YES;
        }
    }];
    return containsTexItem;
}

#pragma mark - TextItemDelegate
- (BOOL)textItemRestrictedPanAreasWithTextItem:(TextItem *)item{
    BOOL hasDeleteCoordinate = CGRectIntersectsRect(self.bottomToolBar.frame, item.frame);
    CGRect rectCoordinate = [item.superview convertRect:item.frame toView:self.editorVC.imageView.superview];
    BOOL beyondBorder = !CGRectIntersectsRect(CGRectInset(self.editorVC.imageView.frame, 30, 30), rectCoordinate);
    
    return beyondBorder && !hasDeleteCoordinate;
}

- (void)textItem:(TextItem *)item translationGesture:(UIPanGestureRecognizer *)gesture activation:(BOOL)activation{
    BOOL hasDeleteCoordinate = CGRectIntersectsRect(self.bottomToolBar.frame, item.frame);
    if (hasDeleteCoordinate) {
        self.bottomToolBar.deleteState = BottomToolDeleteStateDid;
        if (!activation) {
            [item remove];
        }
    }else {
        self.bottomToolBar.deleteState = BottomToolDeleteStateWill;
    }
    
    if (!self.bottomToolBar.isWilShow && activation) {
        [self.bottomToolBar setToolBarShow:YES animation:YES];
    }else if (self.bottomToolBar.isWilShow && !activation) {
        [self.bottomToolBar setToolBarShow:NO animation:YES];
    }
}

- (void)textItemDidClickWithItem:(TextItem *)item{
    [self setup];
}

@end



#pragma mark - ZPTextItem

@interface ZPTextView()<TopToolBarDelegate, UITextViewDelegate, ColorToolBarDelegate>
@property (nonatomic, strong) TopToolBar *topToolBar;
@property (nonatomic, strong) ColorToolBar *colorToolBar;
@property (nonatomic, strong) NSString *needReplaceString;
@property (nonatomic, assign) NSRange needReplaceRange;
@property (nonatomic, assign) BOOL willDisMiss;
@end

@implementation ZPTextView

- (void)setAtts:(NSDictionary *)atts{
    _atts = atts;
    if (!atts.allValues.count) {
        return;
    }
    
    UIColor *fillColor = atts[NSBackgroundColorAttributeName];
    UIColor *strokeColor = atts[NSForegroundColorAttributeName];
    
    self.colorToolBar.changeBgColor = !CGColorEqualToColor(fillColor.CGColor, [UIColor clearColor].CGColor);
    self.colorToolBar.currentColor = self.colorToolBar.changeBgColor ? fillColor : strokeColor;
    
    [self refreshTextViewDisplay];
}

- (void)refreshTextViewDisplay{
    NSDictionary *attributes = nil;
    UIColor *bgcolor = self.colorToolBar.currentColor ? :[UIColor redColor];
    UIColor *textColor = self.colorToolBar.currentColor ? :[UIColor whiteColor];
    UIFont *font = self.inputView.font ? :[UIFont systemFontOfSize:24.f weight:UIFontWeightRegular];
    
    if (self.colorToolBar.isChangeBgColor) {
        // 当处于改变文字背景的模式，背景颜色为白色，文字为黑色，其他情况统一为白色
        if ([self.colorToolBar isWhiteColor]) {
            textColor = [UIColor blackColor];
        }else {
            textColor = [UIColor whiteColor];
        }
        attributes = @{
                       NSFontAttributeName:font,
                       NSForegroundColorAttributeName:textColor,
                       NSBackgroundColorAttributeName:bgcolor
                       };
    }else {
        attributes = @{
                       NSFontAttributeName:font,
                       NSForegroundColorAttributeName:textColor,
                       NSBackgroundColorAttributeName:[UIColor clearColor]
                       };
    }
    self.inputView.attributedText = [[NSAttributedString alloc] initWithString:self.inputView.text
                                                                    attributes:attributes];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.willDisMiss = NO;
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        self.effectView.frame = frame;
        [self addSubview:self.effectView];
        
        self.topToolBar = [[TopToolBar alloc] initWithType:TopToolBarTypeCancelAndDoneIcon];
        self.topToolBar.delegate = self;
        self.topToolBar.frame = CGRectMake(0, 0, Screen_W, kTopHeight);
        [self addSubview:self.topToolBar];
        
        self.inputView = [[UITextView alloc] init];
        CGRect frame = CGRectInset(self.bounds, 15, 0);
        frame.origin.y = CGRectGetMaxY(self.topToolBar.frame);
        frame.size.height -= CGRectGetMaxY(self.topToolBar.frame);
        
        self.inputView.frame = frame;
        self.inputView.scrollEnabled = YES;
        self.inputView.returnKeyType = UIReturnKeyDone;
        self.inputView.backgroundColor = [UIColor clearColor];
        self.inputView.delegate = self;
        [self addSubview:self.inputView];
        
        self.colorToolBar = [[ColorToolBar alloc] initWithType:ColorToolBarTypeText];
        self.colorToolBar.delegate = self;
        self.colorToolBar.frame = CGRectMake(0, 0, Screen_W, TextColorToolBarHeight);
        
        self.inputView.inputAccessoryView = self.colorToolBar;
//        self.inputView.inputAccessoryView.backgroundColor = [UIColor yellowColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

#pragma mark - TopToolBarDelegate
- (void)topToolBar:(TopToolBar *)toolBar event:(TopToolBarEvent)event{
    if (event == TopToolBarEventCancel) {
        [self dismissTextEditing:NO];
    }else{
        [self dismissTextEditing:YES];
    }
}

#pragma mark - ColorToolBarDelegate
- (void)colorToolBar:(ColorToolBar *)toolBar event:(ColorToolBarEvent)event{
    if (event == ColorToolBarEventSelectColor || event == ColorToolBarEventChangeBgColor) {
        [self refreshTextViewDisplay];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    // 选中范围的标记
    UITextRange *textSelectRange = [textView markedTextRange];
    // 获取高亮部分
    UITextPosition *textPosition = [textView positionFromPosition:textSelectRange.start offset:0];
    // 如果在变化中是高亮部分在变， 就不要计算字符l
    if (textSelectRange && textPosition) {
        [self refreshTextViewDisplay];
        return;
    }
    // 文本内容
    NSString *textContentStr = textView.text;
    NSInteger existTextNumber = textContentStr.length;
    if (existTextNumber > kTextMaxLimitNumber) {
        // 截取到最大位置的字符(由于超出截取部分在should时被处理了,所以在这里为了提高效率不在判断)
        NSString *str = [textContentStr substringToIndex:kTextMaxLimitNumber];
        [textView setText:str];
    }
    [self refreshTextViewDisplay];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self dismissTextEditing:YES];
        return NO;
    }
    
    UITextRange *selectRange = [textView markedTextRange];
    // 获取高亮bufen
    UITextPosition *pos = [textView positionFromPosition:selectRange.start offset:0];
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        if (offsetRange.location < kTextMaxLimitNumber && textView.text.length - offsetRange.length <= kTextMaxLimitNumber) {
            self.needReplaceRange = offsetRange;
            self.needReplaceString = text;
            return YES;
        }else{
            return NO;
        }
    }
    
    NSString *comcatStr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger caninputLen = kTextMaxLimitNumber - comcatStr.length;
    if (caninputLen >= 0) {
        return YES;
    }else{
        NSInteger len = text.length + caninputLen;
        NSRange rg = {0, MAX(len, 0)};
        if (rg.length > 0) {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          NSInteger steplen = substring.length;
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx = idx + steplen;//这里变化了，使用了字串占的长度来作为步长
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

#pragma mark - UIKeyboard
- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardAnimationDuriation = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions keyboardAnimationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    self.hidden = YES;
    [UIView animateWithDuration:keyboardAnimationDuriation delay:keyboardAnimationDuriation options:keyboardAnimationCurve animations:^{
        
        CGRect frame = self.inputView.frame;
        frame.size.height = [UIScreen mainScreen].bounds.size.height - keyboardRect.size.height;
        self.inputView.frame = frame;
        
        CGRect frame2 = self.frame;
        frame2.origin.y = 0;
        self.frame = frame2;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:3.0 animations:^{
        self.hidden = NO;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat keyboardAnimationDuriation = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions keyboardAnimationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuriation delay:0.f options:keyboardAnimationCurve animations:^{
        
        CGRect frame = self.frame;
        frame.origin.y = CGRectGetHeight(self.effectView.frame);
        self.frame = frame;
        
    } completion:^(BOOL finished) {
        // 处理非用户操作造成的键盘收起情况，关闭页面，比如收到通话邀请
        if (!self.willDisMiss) {
            [self dismissTextEditing:YES];
        }
        
    }];
}

- (void)dismissTextEditing:(BOOL)done{
    self.willDisMiss = YES;
    NSDictionary *atts = nil;
    if (self.inputView.text.length) {
        NSRange range = NSMakeRange(0, self.inputView.text.length);
        atts = [self.inputView.attributedText attributesAtIndex:0 effectiveRange:&range];
    }
    if (self.dissMissBlock) {
        self.dissMissBlock(self.inputView.text, atts, done);
    }
}

#pragma mark - other
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.inputView becomeFirstResponder];
            [self.inputView scrollRangeToVisible:NSMakeRange(self.inputView.text.length-1, 0)];
        });
    } else {
        
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
