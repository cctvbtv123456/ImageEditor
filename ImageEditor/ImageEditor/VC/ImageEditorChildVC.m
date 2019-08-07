//
//  ImageEditorChildVC.m
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ImageEditorChildVC.h"
#import "TextTool.h"
#import "TextItem.h"
#import "DrawTool.h"
#import "TopToolBar.h"
#import "ImageToolBase.h"

@interface ImageEditorChildVC()<UIScrollViewDelegate, TopToolBarDelegate, BottomToolBarDelegate>
{
    BOOL _originalNavBarHidden;
    BOOL _originalStatusBarHidden;
    BOOL _originalInteractivePopGestureRecognizer;
    UIImage *_originalImage;
}
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ImageToolBase *currentTool;
@property (nonatomic, strong) DrawTool *drawTool;
@property (nonatomic, strong) TextTool *textTool;
@property (nonatomic, assign) BOOL willDisMiss, initializeTools;
@end

@implementation ImageEditorChildVC

- (instancetype)initWithImage:(UIImage *)image
                     delegate:(id<ImageEditorDelegate>)delegate
                   dataSource:(id<ImageEditorDataSource>)dataSource{
    if (self == [super init]) {
        _originalNavBarHidden = self.navigationController.navigationBar.hidden;
        _originalStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            _originalInteractivePopGestureRecognizer = self.navigationController.interactivePopGestureRecognizer.enabled;
        }
        _originalImage = [image ps_imageCompress];
        self.delegate = delegate;
        self.dataSource = dataSource;
 
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = _originalNavBarHidden;
    if (self.willDisMiss) {
        [self.navigationController setNavigationBarHidden:_originalNavBarHidden animated:NO];
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = _originalInteractivePopGestureRecognizer;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.topToolBar setToolBarShow:YES animation:YES];
    [self.bottomToolBar setToolBarShow:YES animation:YES];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!self.initializeTools) {
        [self refreshImageView];
        // 绘图画布的加载顺序：text >draw
        [self.drawTool initialize];
        [self.textTool initialize];
    }
    self.initializeTools = YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupSubView];
}

- (void)setupSubView{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.imageView];
    [self.view addSubview:self.topToolBar];
    [self.view addSubview:self.bottomToolBar];
    
    [self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(ZP_TopToolBarHeight));
    }];
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(@(ZP_BottomToolBarHeight));
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.topToolBar setToolBarShow:NO animation:NO];
    [self.bottomToolBar setToolBarShow:NO animation:NO];
}

#pragma makr - TopToolBarDelegate
- (void)topToolBar:(TopToolBar *)toolBar event:(TopToolBarEvent)event{
    switch (event) {
        case TopToolBarEventCancel:
        {
            [self dismiss];
            if (self.delegate && [self.delegate respondsToSelector:@selector(imageEditorDidCancel)]) {
                [self.delegate imageEditorDidCancel];
            }
        }
            break;
        case TopToolBarEventDone:
        {
            [self buildClipImageCallBack:^(UIImage * _Nonnull clipedImage) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(imageEditor:didFinishEdittingWithImage:)]) {
                    [self.delegate imageEditor:self didFinishEdittingWithImage:clipedImage];
                }
            }];
        }
        default:
            break;
    }
}

#pragma makr - BottomToolBarDelegate
- (void)bottomToolBar:(BottomToolBar *)toolBar
        didClickEvent:(BottomToolBarEvent)event{
    switch (event) {
        case BottomToolBarEventDraw:
            self.editorMode = ImageEditorModeDraw;
            self.currentTool = self.drawTool;
            break;
        case BottomToolBarEventText:
            self.editorMode = ImageEditorModeText;
            self.currentTool = self.textTool;
        default:
            break;
    }
    if (!toolBar.isEditor) {
        self.currentTool = nil;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView.superview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (self.scrollViewDidZoomBlock) {
        self.scrollViewDidZoomBlock(scrollView.zoomScale);
    }
    
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.superview.frame.size.width;
    CGFloat H = _imageView.superview.frame.size.height;
    
    CGRect rect = _imageView.superview.frame;
    rect.origin.x = MAX((Ws - W)/2, 0);
    rect.origin.y = MAX((Hs - H)/2, 0);
    _imageView.superview.frame = rect;
}

#pragma mark - Method
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)buildClipImageCallBack:(void (^)(UIImage * _Nonnull))callBack{
    if (!self.produceChanges) {
        if (callBack) {
            callBack(_originalImage);
        }
        return;
    }
    
    UIImageView *imageView = self.imageView;
    UIImageView *drawingView = self.drawTool->_drewingView;
    
    UIGraphicsBeginImageContextWithOptions(imageView.image.size, NO, [UIScreen mainScreen].scale);
    // 画笔
    [imageView.image drawAtPoint:CGPointZero];

    [drawingView.image drawInRect:CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
    // 文字
    for (UIView *view in self.view.subviews) {
        if (![view isKindOfClass:[TextItem class]]) { continue; }
        
        TextItem *texItem = (TextItem *)view;
        [TextItem setInactiveTextView:texItem];
        
        CGFloat rotation = [[texItem.layer valueForKeyPath:@"transform.rotation.z"] doubleValue];
        CGFloat selfRw = imageView.bounds.size.width / imageView.image.size.width;
        CGFloat selfRh = imageView.bounds.size.height / imageView.image.size.height;
        
        CGRect texItemRect = [texItem.superview convertRect:texItem.frame toView:self.imageView.superview];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *textImg = [UIImage ps_screenshot:texItem];
            textImg = [textImg ps_imageRotatedByRadians:rotation];
            CGFloat sw = textImg.size.width / selfRw;
            CGFloat sh = textImg.size.height / selfRh;
            [textImg drawInRect:CGRectMake(texItemRect.origin.x/selfRw, texItemRect.origin.y/selfRh, sw, sh)];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImage *image = [UIImage imageWithCGImage:tmp.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        if (callBack) { callBack(image); }
    });
}

- (void)resetImageViewFrame {
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    _imageView.frame = CGRectMake(0, 0, W, H);
    _imageView.superview.bounds = _imageView.bounds;
}

- (void)resetZoomScaleWithAnimate:(BOOL)animated {
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:_scrollView];
}

- (void)refreshImageView{
    if (!_originalImage) {
        return;
    }
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimate:NO];
}

- (void)singleGestureClicked{
    BOOL show = !self.topToolBar.isShow;
    [self hiddenToolBar:!show animation:YES];
}

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation {
    
    if (self.editorMode == ImageEditorModeDraw) {
        [self.drawTool hiddenToolBar:hidden animation:animation];
    }else if (self.editorMode == ImageEditorModeText) {
        [self.textTool hiddenToolBar:hidden animation:animation];
    }
    
    [self.topToolBar setToolBarShow:!hidden animation:animation];
    [self.bottomToolBar setToolBarShow:!hidden animation:animation];
}

- (void)dismiss{
    self.willDisMiss = YES;
    if (self.presentationController && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Getter/Setter
- (BOOL)produceChanges{
    return self.drawTool.produceChanges || self.textTool.produceChanges;
}

- (void)setCurrentTool:(ImageToolBase *)currentTool{
    if (currentTool != _currentTool) {
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        if (!currentTool) {
            self.editorMode = ImageEditorModeNone;
        }
    }
}

- (UIScrollView *)scrollView{
    return LAZY_LOAD(_scrollView, ({
//        _scrollView = [[UIScrollView alloc] init];
//        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _scrollView.delegate = self;
//        _scrollView.multipleTouchEnabled = YES;
//        _scrollView.showsHorizontalScrollIndicator = NO;
//        _scrollView.showsVerticalScrollIndicator = NO;
//        _scrollView.delaysContentTouches = NO;
//        _scrollView.scrollsToTop = NO;
//        _scrollView.clipsToBounds = NO;
//        if(@available(iOS 11.0, *)) {
//            _scrollView.contentInsetAdjustmentBehavior =
//            UIScrollViewContentInsetAdjustmentNever;
//        }
//        UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleGestureClicked)];
//        [_scrollView addGestureRecognizer:singleGesture];
//        _scrollView;
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delaysContentTouches = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.clipsToBounds = NO;
        if(@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior =
            UIScrollViewContentInsetAdjustmentNever;
        }
        UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleGestureClicked)];
        [_scrollView addGestureRecognizer:singleGesture];
        _scrollView;
    }));
}

- (UIView *)contentView{
    return LAZY_LOAD(_contentView, ({
        _contentView = [[UIView alloc] init];
        _contentView;
    }));
}

- (UIImageView *)imageView{
    return LAZY_LOAD(_imageView, ({
        _imageView = [[UIImageView alloc] initWithImage:_originalImage];
        _imageView.clipsToBounds = YES;
        _imageView;
    }));
}

- (TopToolBar *)topToolBar{
    return LAZY_LOAD(_topToolBar, ({
        _topToolBar = [[TopToolBar alloc] initWithType:TopToolBarTypeCancelAndDoneText];
        _topToolBar.delegate = self;
        _topToolBar;
    }));
}

- (BottomToolBar *)bottomToolBar{
    return LAZY_LOAD(_bottomToolBar, ({
        _bottomToolBar = [[BottomToolBar alloc] initWithType:BottomToolTypeEditor];
        _bottomToolBar.delegate = self;
        _bottomToolBar;
    }));
}

- (TextTool *)textTool{
    return LAZY_LOAD(_textTool, ({
        _textTool = [[TextTool alloc] initWithImageEditor:self option:[self textToolOption]];
        __weak typeof(self) weakSelf = self;
        _textTool.dissmissCallBack = ^(NSString * _Nonnull currentText) {
            [weakSelf.textTool cleanup];
            weakSelf.currentTool = nil;
            [weakSelf.bottomToolBar reset];
        };
        _textTool;
    }));
}

- (DrawTool *)drawTool{
    return LAZY_LOAD(_drawTool, ({
        _drawTool = [[DrawTool alloc] initWithImageEditor:self option:[self drawToolOption]];
        _drawTool;
    }));
}

- (NSDictionary *)drawToolOption {
    NSMutableDictionary *option = [NSMutableDictionary dictionary];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageEditorDefaultColor)]) {
        UIColor *defaultColor = [self.dataSource imageEditorDefaultColor];
        [option setObject:defaultColor ?:[UIColor redColor] forKey:kImageToolDrawLineColorKey];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageEditorDrawPathWidth)]) {
        CGFloat drawPathWidth = [self.dataSource imageEditorDrawPathWidth];
        [option setObject:@(MAX(1, drawPathWidth)) forKey:kImageToolDrawLineWidthKey];
    }
    return option;
}

- (NSDictionary *)textToolOption {
    NSMutableDictionary *option = [NSMutableDictionary dictionary];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageEditorDefaultColor)]) {
        UIColor *defaultColor = [self.dataSource imageEditorDefaultColor];
        [option setObject:defaultColor ?:[UIColor redColor] forKey:kImageToolTextColorKey];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:
                            @selector(imageEditorTextFont)]) {
        UIFont *textFont = [self.dataSource imageEditorTextFont];
        [option setObject:(textFont ? :[UIFont systemFontOfSize:24.0f]) forKey:kImageToolTextFontKey];
    }
    return option;
}

@end
