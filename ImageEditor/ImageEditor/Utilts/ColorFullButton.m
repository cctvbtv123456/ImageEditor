//
//  ColorFullButton.m
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ColorFullButton.h"

@interface ColorFullButton()
{
    UIColor *_color;
    CGFloat _radius;
}
@end

@implementation ColorFullButton

- (void)setRadius:(CGFloat)radius{
    _radius = radius;
    [self drewCirle];
}

- (void)setColor:(UIColor *)color{
    _color = color;
    [self drewCirle];
}

- (void)setIsUse:(BOOL)isUse{
    _isUse = isUse;
    [self drewCirle];
}

- (void)drewCirle{
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    UIGraphicsBeginImageContext(self.bounds.size);
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f) radius:_isUse?_radius+3*kScale:_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    layer.fillColor = _color.CGColor;
    layer.allowsEdgeAntialiasing = YES;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.lineWidth = _isUse ? 3.0f*kScale : 1.0f;
    layer.path = path.CGPath;
    [path fill];
    UIGraphicsEndImageContext();
    [self.layer addSublayer:layer];
}

@end
