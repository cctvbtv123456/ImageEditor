//
//  ViewController.m
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ViewController.h"
#import "ImageEditorVC.h"

@interface ViewController ()<ImageEditorDataSource, ImageEditorDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)click:(UIButton *)sender {
    UIImage *image = [UIImage imageNamed:@"localImage_01@2x.jpeg"];
    ImageEditorVC *imageEditorVC = [[ImageEditorVC alloc] initWithImage:image delegate:self dataSource:self];
    [self.navigationController pushViewController:imageEditorVC animated:YES];
}

#pragma mark - ImageEditorDataSource
- (UIColor *)imageEditorDefaultColor{
    return [UIColor redColor];
}
- (CGFloat)imageEditorDrawPathWidth{
    return 5;
}
- (UIFont *)imageEditorTextFont{
    return [UIFont boldSystemFontOfSize:24];
}

#pragma mark - ImageEditorDelegate
- (void)imageEditor:(ImageEditorVC *)editor didFinishEdittingWithImage:(UIImage *)image{
    NSLog(@"%s",__func__);
    
}
- (void)imageEditorDidCancel{
    NSLog(@"%s",__func__);
}

@end
