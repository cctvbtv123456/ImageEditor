//
//  ImageEditorVC.m
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ImageEditorVC.h"
#import "ImageEditorChildVC.h"

@interface ImageEditorVC ()

@end

@implementation ImageEditorVC

- (instancetype)initWithImage:(UIImage *)image{
    return [self initWithImage:image delegate:nil dataSource:nil];
}

- (instancetype)initWithImage:(UIImage *)image delegate:(id<ImageEditorDelegate>)delegate dataSource:(id<ImageEditorDataSource>)dataSource{
    return [[ImageEditorChildVC alloc] initWithImage:image delegate:delegate dataSource:dataSource];
}

- (void)dismiss{}

@end
