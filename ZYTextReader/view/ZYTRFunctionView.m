//
//  ZYTRFunctionView.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/8/8.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRFunctionView.h"
#import "ZYTRCommon.h"

@implementation ZYTRFunctionView {
    BOOL _alreadyDraw;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //翻转坐标系
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    //    CGContextScaleCTM(context, 1.0, -1.0);
    if (self.pointArr.count) {        //画线
        CGContextSetLineWidth(context, 2.0);
        CGContextSetRGBStrokeColor(context, 0.314, 0.486, 0.859, 1.0);
        CGContextBeginPath(context);
        [_pointArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *pinfo = (NSDictionary *)obj;
            CGPoint startPoint = CGPointFromString([pinfo valueForKey:@"startP"]);
            CGPoint endPoint = CGPointFromString([pinfo valueForKey:@"endP"]);
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        }];
        CGContextStrokePath(context);
        _alreadyDraw = YES;
    }else {
        if (_alreadyDraw) {
            CGContextClearRect(context, rect);
            _alreadyDraw = NO;
        }
    }
}

- (NSArray *)pointArrWithRectArr:(NSArray *)rects fromView:(UIView *)fromeView {
    NSMutableArray *pinfoArr = @[].mutableCopy;
    [rects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rectV = [(NSValue *)obj CGRectValue];
        CGRect newRec = [fromeView convertRect:rectV toView:self];
        NSDictionary *pInfo = [self bottomPointInfoWithRect:newRec];
        [pinfoArr addObject:pInfo];
    }];
    return pinfoArr;
}

- (NSDictionary *)bottomPointInfoWithRect:(CGRect)rect {
    CGFloat xStart = rect.origin.x;
    CGFloat xEnd = rect.origin.x + rect.size.width;
    CGFloat Y = rect.origin.y + rect.size.height + 2;
    return @{@"startP": NSStringFromCGPoint(CGPointMake(xStart, Y)), @"endP":NSStringFromCGPoint(CGPointMake(xEnd, Y))};
}

@end
