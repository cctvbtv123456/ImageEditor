//
//  DrewTool.m
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "DrawTool.h"
#import "ColorToolBar.h"

@interface DrawTool()<ColorToolBarDelegate>

@property (nonatomic, assign) CGFloat drawLineWidth;

@property (nonatomic, strong) UIColor *drawLineColor;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) ColorToolBar *colorToolBar;

@property (nonatomic, strong) NSMutableArray<DrewPath *> *drawPaths;

@end

@implementation DrawTool{
    CGSize _originImageSize;
}

- (instancetype)initWithImageEditor:(ImageEditorVC *)editorVC option:(NSDictionary *)option{
    
    if (self = [super initWithImageEditor:editorVC option:option]) {
        
        _drawPaths = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)initialize{
    
    if (!_drewingView) {
        _originImageSize = self.editorVC.imageView.image.size;
        _drewingView = [[UIImageView alloc] initWithFrame:self.editorVC.imageView.bounds];
        _drewingView.layer.shouldRasterize = YES;
        _drewingView.layer.minificationFilter = kCAFilterTrilinear;
        [self.editorVC.imageView addSubview:_drewingView];
    }
}

- (void)resetRect:(CGRect)rect{
    
    _drewingView.image = nil;
    _originImageSize = self.editorVC.imageView.image.size;
    _drewingView.frame = self.editorVC.imageView.bounds;
    [_drawPaths removeAllObjects];
    [self refreshCanUndoButtonState];
}

- (void)refreshCanUndoButtonState{
    self.colorToolBar.canUndo = _drawPaths.count;
    self.produceChanges = _drawPaths.count;
}

- (void)setup{
    
    _originImageSize = self.editorVC.imageView.image.size;
    
    _drewingView.frame = self.editorVC.imageView.bounds;
    _drewingView.userInteractionEnabled = YES;
    self.editorVC.imageView.userInteractionEnabled = YES;
    self.editorVC.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.editorVC.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.editorVC.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    if (!_drawLineColor) {
        _drawLineColor = self.option[kImageToolDrawLineColorKey];
    }
    _drawLineWidth = [self.option[kImageToolDrawLineWidthKey] floatValue];
    
    if (!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
        self.panGesture.maximumNumberOfTouches = 1;
        [_drewingView addGestureRecognizer:self.panGesture];
    }
    
    if (!self.panGesture.isEnabled) {
        self.panGesture.enabled = YES;
    }
    
    if (!self.colorToolBar) {
        self.colorToolBar = [[ColorToolBar alloc] initWithType:ColorToolBarTypeColor];
        self.colorToolBar.delegate = self;
        [self.editorVC.view addSubview:self.colorToolBar];
        
        [self.colorToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.editorVC.view);
            make.height.equalTo(@(ZP_DrawColorToolBarHeight));
            make.bottom.equalTo(self.editorVC.bottomToolBar.tempEditorItem.mas_top).offset(-15*ZP_kScale);
        }];
    }
    
    [self refreshCanUndoButtonState];
    [self.colorToolBar setToolBarShow:YES animation:YES];
}

- (void)cleanup{
    
    _drewingView.userInteractionEnabled = YES;
    self.editorVC.imageView.userInteractionEnabled = NO;
    self.editorVC.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGesture.enabled = NO;
    
    [self.colorToolBar setToolBarShow:NO animation:NO];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage * _Nonnull, NSError * _Nonnull, NSDictionary * _Nonnull))completionBlock{
    
    UIImage *backGroundImage = self.editorVC.imageView.image;
    UIImage *foreGroundImage = _drewingView.image;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImageWithBackGroundImage:backGroundImage foreGroundImage:foreGroundImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation{
    [self.colorToolBar setToolBarShow:!hidden animation:animation];
}

- (UIImage *)buildImageWithBackGroundImage:(UIImage *)backGroundImage foreGroundImage:(UIImage *)foreGroungImage{
    UIGraphicsBeginImageContextWithOptions(_originImageSize, NO, backGroundImage.scale);
    [backGroundImage drawAtPoint:CGPointZero];
    [backGroundImage drawInRect:CGRectMake(0, 0, _originImageSize.width, _originImageSize.height)];
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tmp;
}

#pragma mark - 根据手势路径画线
- (void)drawingViewDidPan:(UIPanGestureRecognizer *)sender{
    
    CGPoint currentDraggingPosition = [sender locationInView:_drewingView];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        // 初始化一个UIBezierPath对象，把起始点存储到UIBezierPath对象中，用来存储所偶遇轨迹点
        DrewPath *path = [DrewPath pathToPoint:currentDraggingPosition pathWidth:MAX(1, self.drawLineWidth)];
        path.pathColor = self.drawLineColor;
        path.shape.strokeColor = self.drawLineColor.CGColor;
        [_drawPaths addObject:path];
        [self.editorVC hiddenToolBar:YES animation:YES];
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        // 获得数组中的最后一个UIBezierPath对象 (因为我们每次都把UIBezierPath存入到数组最后一个，因此获取时也取最后一个)
        DrewPath *path = [_drawPaths lastObject];
        [path pathLineToPoint:currentDraggingPosition];
        [self drawLine];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self refreshCanUndoButtonState];
//        [self.editorVC hiddenToolBar:NO animation:YES];
    }
    
}

- (void)drawLine{
    CGSize size = _drewingView.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 去掉锯齿
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    for (DrewPath *path in _drawPaths) {
        [path drewPath];
    }
    _drewingView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

#pragma mark - ColorToolBarDelegate
- (void)colorToolBar:(ColorToolBar *)toolBar event:(ColorToolBarEvent)event{
    switch (event) {
        case ColorToolBarEventSelectColor:
        {
            _drawLineColor = toolBar.currentColor;
        }
            break;
        case ColorToolBarEventUndo:
        {
            [self undoToLastDraw];
        }
            break;
            
        default:
            break;
    }
}

- (void)undoToLastDraw{
    
    if (!_drawPaths.count) {
        return;
    }
    [_drawPaths removeLastObject];
    [self drawLine];
    [self refreshCanUndoButtonState];
}

@end



@interface DrewPath()

@property (nonatomic, strong) UIBezierPath *bezierPath;

@property (nonatomic, assign) CGPoint beginPoint;

@property (nonatomic, assign) CGFloat pathWidth;

@end

@implementation DrewPath

+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth{
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = pathWidth;
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    [bezierPath moveToPoint:beginPoint];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = pathWidth;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.path = bezierPath.CGPath;
    
    DrewPath *path = [[DrewPath alloc] init];
    path.beginPoint = beginPoint;
    path.pathWidth = pathWidth;
    path.bezierPath = bezierPath;
    path.shape = shapeLayer;
    
    return path;
}

- (void)pathLineToPoint:(CGPoint)movePoint{
    
    [self.bezierPath addLineToPoint:movePoint];
    self.shape.path = [self.bezierPath CGPath];
}

- (void)drewPath{
    [self.pathColor set];
    [self.bezierPath stroke];
}

@end
