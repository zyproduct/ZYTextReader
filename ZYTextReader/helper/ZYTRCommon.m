//
//  ZYTRCommon.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRCommon.h"

@implementation ZYTRCommon

ZYTRPosition const PositionNull = {MAXFLOAT,MAXFLOAT,MAXFLOAT,MAXFLOAT};

ZYTRPosition const PositionZero = {0,0,0,0};

#pragma mark 获取frame

///获取镜像frame
CGRect convertRect(CGRect rect,CGFloat height) {
    if (CGRectEqualToRect(rect, CGRectNull)) {
        return CGRectNull;
    }
    return CGRectMake(rect.origin.x, height - rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
}

CGFloat getCTFramePahtXOffset(CTFrameRef frame) {
    CGPathRef path = CTFrameGetPath(frame);
    CGRect colRect = CGPathGetBoundingBox(path);
    return colRect.origin.x;
}

CGSize getCTFrameSize(CTFrameRef frame) {
    CGPathRef path = CTFrameGetPath(frame);
    CGRect colRect = CGPathGetBoundingBox(path);
    return colRect.size;
}

CGRect getRectWithCTFramePathOffset(CGRect rect,CTFrameRef frame) {
    CGPathRef path = CTFrameGetPath(frame);
    CGRect colRect = CGPathGetBoundingBox(path);
    return CGRectOffset(rect, colRect.origin.x, colRect.origin.y);
}

//
CGRect getCTLineBounds(CTFrameRef frame,CTLineRef line,CGPoint origin) {
    CGFloat lineAscent;
    CGFloat lineDescent;
    CGFloat lineWidth = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
    CGRect boundsLine = CGRectMake(0, - lineDescent, lineWidth, lineAscent + lineDescent);
    boundsLine = CGRectOffset(boundsLine, origin.x, origin.y);
    return getRectWithCTFramePathOffset(boundsLine, frame);
}

CGRect getCTRunBounds(CTFrameRef frame,CTLineRef line,CGPoint origin,CTRunRef run) {
    CGFloat ascent;
    CGFloat descent;
    CGRect boundsRun = CGRectZero;
    boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
    boundsRun.size.height = ascent + descent;
    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
    boundsRun.origin.x = origin.x + xOffset;
    boundsRun.origin.y = origin.y - descent;
    return getRectWithCTFramePathOffset(boundsRun, frame);
}

///返回给定点是否在给定尺寸的修正范围内
BOOL rectFixContainsPoint(CGRect rect,CGPoint point) {
    rect = CGRectInset(rect, 0, -0.25);
    return CGRectContainsPoint(rect, point);
}

#pragma mark 空间位置关系

NSComparisonResult PointInRectV(CGPoint point,CGRect rect) {
    return NumBetweenAB(point.y, CGRectGetMinY(rect), CGRectGetMaxY(rect));
}

NSComparisonResult PointInRectH(CGPoint point,CGRect rect) {
    return NumBetweenAB(point.x, CGRectGetMinX(rect), CGRectGetMaxX(rect));
}

NSComparisonResult NumBetweenAB(CGFloat num,CGFloat a,CGFloat b) {
    if (a > b) {
        SwapfAB(&a, &b);
    }
    if (num < a) {
        if (FixEqual(a,num)) {
            return NSOrderedSame;
        }
        return NSOrderedAscending;
    } else if (num > b) {
        if (FixEqual(b,num)) {
            return NSOrderedSame;
        }
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

//比较指定坐标在给定尺寸中的位置
NSComparisonResult CompareXCrdWithRect(CGFloat xCrd,CGRect rect) {
    CGFloat min = CGRectGetMinX(rect);
    CGFloat max = CGRectGetMaxX(rect);
    return NumBetweenAB(xCrd, min, max);
}

///返回距离指定坐标较近的一侧的坐标值
CGFloat ClosestSide(CGFloat xCrd,CGFloat left,CGFloat right) {
    if (right < left) {
        SwapfAB(&left, &right);
    }
    CGFloat mid = (left + right) / 2;
    if (xCrd > mid) {
        return right;
    } else {
        return left;
    }
}

#pragma mark 尺寸修正
CGRect ShortenRectToXCrd(CGRect rect,CGFloat xCrd,BOOL backward) {
    if (!backward && xCrd == CGRectGetMaxX(rect)) {
        return rect;
    }
    if (backward && xCrd == CGRectGetMinX(rect)) {
        return rect;
    }
    NSComparisonResult result = CompareXCrdWithRect(xCrd, rect);
    if (result == NSOrderedSame) {
        return FixRectToXCrd(rect, xCrd, result, backward);
    } else {
        return CGRectZero;
    }
}

CGRect FixRectToXCrd(CGRect rect,CGFloat xCrd,NSComparisonResult result,BOOL backward) {
    if (CGRectEqualToRect(rect, CGRectZero)) {
        return CGRectZero;
    }
    if (result == NSOrderedDescending) {
        rect.size.width = xCrd - rect.origin.x;
    } else if (result == NSOrderedAscending) {
        rect.size.width += rect.origin.x - xCrd;
        rect.origin.x = xCrd;
    } else if (backward) {
        rect.size.width += rect.origin.x - xCrd;
        rect.origin.x = xCrd;
    } else {
        rect.size.width = xCrd - rect.origin.x;
    }
    if (CGRectGetWidth(rect) <= 0) {
        return CGRectZero;
    }
    return rect;
}

#pragma mark 交换
///交换浮点数
void SwapfAB(CGFloat *a,CGFloat *b) {
    CGFloat temp = *a;
    *a = *b;
    *b = temp;
}

///交换对象
void SwapoAB(id a,id b) {
    id temp = a;
    a = b;
    b = temp;
}


#pragma mark Helper

ZYTRPosition MakePosition(CGFloat baseLineY,CGFloat xCrd,CGFloat height,NSUInteger index) {
    return (ZYTRPosition){baseLineY,xCrd,height,index};
}

BOOL PositionEqualToPosition(ZYTRPosition p1,ZYTRPosition p2) {
    return (p1.baseLineY == p2.baseLineY) && (p1.xCrd == p2.xCrd) && (p1.height == p2.height);
}

BOOL PositionIsNull(ZYTRPosition p) {
    return PositionEqualToPosition(p, PositionNull);
}

BOOL PositionIsZero(ZYTRPosition p) {
    return PositionEqualToPosition(p, PositionZero);
}

CGRect CGRectFromPosition(ZYTRPosition p,CGFloat width) {
    if (PositionIsNull(p) || width == CGFLOAT_MAX) {
        return CGRectNull;
    }
    return CGRectMake(p.xCrd, p.baseLineY - p.height, width, p.height);
}

NSRange const NSRangeNull = {MAXFLOAT,MAXFLOAT};

NSRange const NSRangeZero = {0,0};

NSRange NSMakeRangeBetweenLocation(NSUInteger loc1,NSUInteger loc2) {
    if (loc1 > loc2) {
        NSUInteger temp = loc1;
        loc1 = loc2;
        loc2 = temp;
    }
    return NSMakeRange(loc1, loc2 - loc1);
}

NSComparisonResult ComparePosition(ZYTRPosition p1,ZYTRPosition p2) {
    if (p1.index == p2.index) {
        return NSOrderedSame;
    } else if (p1.index < p2.index) {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}

BOOL FixEqual(CGFloat a,CGFloat b) {
    if (fabs(a - b) < 1e-6) {
        return YES;
    }
    return NO;
}

@end
