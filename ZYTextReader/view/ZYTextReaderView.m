//
//  ZYTextReaderView.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTextReaderView.h"

@interface ZYTextReaderView ()

@end

@implementation ZYTextReaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)dealloc {
    self.data = nil;
}

#pragma mark drawRect
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //翻转坐标系
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
        for (ZYTextRunWrapper *runWrapper in self.data.layout.imgArr) {
            UIImage *img = [UIImage imageNamed:runWrapper.imageName];
            CGContextDrawImage(context, runWrapper.imageRect, img.CGImage);
        }
    }
}

- (NSDictionary *)imageInfoAtPoint:(CGPoint)point {
    if (self.data.layout.imgArr.count) {
        for (ZYTextRunWrapper *runWrapper in self.data.layout.imgArr) {
            CGRect finalImgRect = convertRect(runWrapper.imageRect, self.height);//CGRectMake(runWrapper.imageRect.origin.x, self.height - runWrapper.imageRect.origin.y, runWrapper.imageRect.size.width, runWrapper.imageRect.size.height);
            if (CGRectContainsPoint(finalImgRect, point)) {
                return @{@"imgName":runWrapper.imageName, @"imgRect":[NSValue valueWithCGRect:finalImgRect]};
            }
        }
        return nil;
    }else {
        return nil;
    }
}

@end
