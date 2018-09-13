//
//  ZYMangifiterView.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/11.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYMangifiterView.h"

@implementation ZYMangifiterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, 80, 80)]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.layer.cornerRadius = 40.0f;
        self.layer.borderWidth = 1;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setTouchPoint:(CGPoint)touchPoint {
    _touchPoint = touchPoint;
    self.center = CGPointMake(touchPoint.x, touchPoint.y - 70);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, self.frame.size.width*0.5, self.frame.size.height*0.5);
    CGContextScaleCTM(context, 1.5, 1.5);
    CGContextTranslateCTM(context, -1*(_touchPoint.x), -1*(_touchPoint.y));
    
    [self.showView.layer renderInContext:context];
}

@end
