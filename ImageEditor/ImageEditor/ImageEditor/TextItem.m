//
//  TextItem.m
//  ImageEditor
//
//  Created by Justin on 2019/8/4.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "TextItem.h"
#import "TextTool.h"
#import "ImageEditorGestureManager.h"

static const CGFloat kMaxFontSize = 50.0f;
static const CGFloat kMinTextScal = 0.614f;
static const CGFloat kMaxTextScal = 4.0f;
static const CGFloat kLabelMinSize = 20;
static const CGFloat kTextBoardItemInset = 20;

@interface TextItem()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) TextTool *textTool;

@end

@implementation TextItem{
    UILabel *_label;
    CGFloat _scale;
    CGFloat _arg;
    CGFloat _rotation;
}

static TextItem *activeView = nil;

+ (void)setActiveTextView:(TextItem *)view{
    
    if (view != activeView) {
        activeView.active = NO;
        activeView = view;
        activeView.active = YES;
        [activeView.superview bringSubviewToFront:activeView];
    }
}

+ (void)setInactiveTextView:(TextItem *)view{
    if (activeView) {
        activeView = nil;
    }
    view.active = NO;
}

- (instancetype)initWithTool:(TextTool *)tool
                        text:(NSString *)text
                        font:(UIFont *)font{
    if (self = [super init]) {
        _textTool = tool;
        
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
        _label.font = font;
        _label.minimumScaleFactor = font.pointSize * 0.8f;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.text = text;
        _label.layer.allowsEdgeAntialiasing = true;
        self.text = text;
        [self addSubview:_label];
        
        _arg = 0;
        
        [self setScale:1];
        [self initGestures];
        [self resizeSelf];
        [self afterInactiveTextView];
    }
    return self;
}

- (void)setScale:(CGFloat)scale {
    
    _scale = scale;
    
    self.transform = CGAffineTransformIdentity;
    
    _label.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (CGRectGetWidth(_label.frame) + 32)) / 2;
    rct.origin.y += (rct.size.height - (CGRectGetHeight(_label.frame) + 32)) / 2;
    rct.size.width  = CGRectGetWidth(_label.frame) + 32;
    rct.size.height = CGRectGetHeight(_label.frame) + 32;
    self.frame = rct;
    
    _label.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    self.layer.borderWidth = 1/_scale;
}


- (void)initGestures{
    _label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPinch:)];
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidRotation:)];
    
    [pinch requireGestureRecognizerToFail:tap];
    [rotation requireGestureRecognizerToFail:tap];
    [_textTool.editorVC.scrollView.panGestureRecognizer requireGestureRecognizerToFail:pan];
    
    tap.delegate = [ImageEditorGestureManager instance];
    pan.delegate = [ImageEditorGestureManager instance];
    pinch.delegate = [ImageEditorGestureManager instance];
    rotation.delegate = [ImageEditorGestureManager instance];
    
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:pinch];
    [self addGestureRecognizer:rotation];
}

- (void)resizeSelf {
    
    CGSize size = [_label sizeThatFits:CGSizeMake(CGRectGetWidth(_textTool.editorVC.imageView.frame) - 2*kTextBoardItemInset, FLT_MAX)];
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake(kLabelMinSize, kLabelMinSize);
    }
    // 处理计算误差 +2
    _label.frame = CGRectMake(kTextBoardItemInset, kTextBoardItemInset, size.width +2, size.height);
    
    self.bounds = CGRectMake(0, 0, CGRectGetWidth(_label.frame) + 2*kTextBoardItemInset, CGRectGetHeight(_label.frame) + 2*kTextBoardItemInset);
}

- (void)afterInactiveTextView {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self class]  setInactiveTextView:self];
    });
}

- (void)remove{
    [[self class] setActiveTextView:self];
    [self removeFromSuperview];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return self;
    }
    return view;
}

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation {
    [_textTool.editorVC hiddenToolBar:hidden animation:animation];
}

#pragma mark- gesture events
- (void)viewDidTap:(UITapGestureRecognizer*)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if(self.active){
            [self textBoardItemDidTap:sender];
        }
        [[self class] setActiveTextView:self];
        [self afterInactiveTextView];
        [self hiddenToolBar:NO animation:YES];
    }
}

- (void)viewDidPan:(UIPanGestureRecognizer*)recognizer {
    
    [[self class] setActiveTextView:self];
    UIView *piece = self;
    CGPoint translation = [recognizer translationInView:piece.superview];
    piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:piece.superview];
    
    BOOL activation = (recognizer.state == UIGestureRecognizerStateBegan ||
                       recognizer.state == UIGestureRecognizerStateChanged);
    
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        [self hiddenToolBar:YES animation:YES];
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateFailed ||
               recognizer.state == UIGestureRecognizerStateCancelled) {
        BOOL restrictedPanAreas = NO;
        if (self.delegate && [self.delegate respondsToSelector:
                              @selector(textItemRestrictedPanAreasWithTextItem:)]) {
            restrictedPanAreas = [self.delegate textItemRestrictedPanAreasWithTextItem:self];
        }
        if (restrictedPanAreas) {
            [UIView animateWithDuration:.2f animations:^{
                piece.center = piece.superview.center;
                self.center = piece.center;
            }];
        }
        
        [self hiddenToolBar:NO animation:YES];
        [self afterInactiveTextView];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:
                          @selector(textItem:translationGesture:activation:)]) {
        [self.delegate textItem:self translationGesture:recognizer activation:activation];
    }
    
    [self layoutSubviews];
}

- (void)viewDidPinch:(UIPinchGestureRecognizer *)recognizer {
    
    //缩放
    [[self class] setActiveTextView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        
        [self hiddenToolBar:YES animation:YES];
        
        //坑点：recognizer.scale是相对原图片大小的scal
        CGFloat scale = [(NSNumber *)[self valueForKeyPath:@"layer.transform.scale.x"] floatValue];
        CGFloat currentScale = recognizer.scale;
        
        if (scale > kMaxTextScal && currentScale > 1) {
            return;
        }
        
        if (scale < kMinTextScal && currentScale < 1) {
            return;
        }
        
        self.transform = CGAffineTransformScale(self.transform, currentScale, currentScale);
        recognizer.scale = 1.0;
        [self layoutSubviews];
        [self hiddenToolBar:YES animation:YES];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateFailed ||
               recognizer.state == UIGestureRecognizerStateCancelled) {
        [self hiddenToolBar:NO animation:YES];
        [self afterInactiveTextView];
    }
}

- (void)viewDidRotation:(UIRotationGestureRecognizer *)recognizer {
    //旋转
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformRotate(self.transform, recognizer.rotation);
        _rotation = _rotation + recognizer.rotation;
        recognizer.rotation = 0;
        [self layoutSubviews];
        [self hiddenToolBar:YES animation:YES];
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateFailed ||
               recognizer.state == UIGestureRecognizerStateCancelled) {
        [self hiddenToolBar:NO animation:YES];
        [self afterInactiveTextView];
    }
}




- (void)textBoardItemDidTap:(UITapGestureRecognizer *)recognizer {
    
    _textTool.isEditAgain = YES;
    _textTool.textView.inputView.text = self.text;
    _textTool.textView.inputView.font = self.font;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textItemDidClickWithItem:)]) {
        [self.delegate textItemDidClickWithItem:self];
    }
    
    __weak typeof (self)weakSelf = self;
    //  再次编辑成功
    _textTool.editAgainCallBack = ^(NSString *text, NSDictionary *attrs) {
        
        weakSelf.text = text;
        [weakSelf resizeSelf];
        
        UIColor *fillColor = attrs[NSBackgroundColorAttributeName];
        UIColor *strokeColor = attrs[NSForegroundColorAttributeName];
        UIFont *font = attrs[NSFontAttributeName];
        
        weakSelf.font = font;
        weakSelf.strokeColor = strokeColor;
        weakSelf.fillColor = fillColor;
    };
}


#pragma mark- Properties
- (void)setActive:(BOOL)active {
    
    _active = active;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.layer.borderWidth = (active) ? 1/_scale : 0;
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset= CGSizeMake(0, 0);
    self.layer.shadowOpacity = .6f;
    self.layer.shadowRadius = 2.f;
    
    [CATransaction commit];
}

- (void)changeColor:(NSNotification *)notification {
    UIColor *currentColor = (UIColor *)notification.object;
    self.fillColor = currentColor;
}

- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight {
    
    self.transform = CGAffineTransformIdentity;
    _label.transform = CGAffineTransformIdentity;
    
    CGSize size = [_label sizeThatFits:CGSizeMake(width / (15/kMaxFontSize), FLT_MAX)];
    _label.frame = CGRectMake(16, 16, size.width, size.height);
    
    CGFloat viewW = (CGRectGetWidth(_label.frame) + 32);
    CGFloat viewH = _label.font.lineHeight;
    
    CGFloat ratio = MIN(width / viewW, lineHeight / viewH);
    [self setScale:ratio];
}


- (void)setFont:(UIFont *)font {
    _label.font = font;
}

- (UIFont*)font {
    return _label.font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _label.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment {
    return _label.textAlignment;
}

- (void)setText:(NSString *)text {
    _text = text;
    _label.text = text;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _label.textColor = strokeColor;
}

- (UIColor *)strokeColor {
    return _label.textColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor*)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setFillColor:(UIColor *)fillColor {
    _label.backgroundColor = fillColor;
}

- (UIColor *)fillColor {
    return _label.backgroundColor;
}

@end
