//
//  ImageToolBase.m
//  ImageEditor
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ImageToolBase.h"

@implementation ImageToolBase

- (instancetype)initWithImageEditor:(ImageEditorVC *)editorVC
                             option:(NSDictionary *)option{
    if (self == [super init]) {
        self.editorVC = editorVC;
        self.option = option;
    }
    return self;
}

- (void)initialize{
    
}
- (void)setup{
    
}
- (void)cleanup{
    
}
- (void)resetRect:(CGRect)rect{
    
}
- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock{
    
}
- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation{
    
}

@end
