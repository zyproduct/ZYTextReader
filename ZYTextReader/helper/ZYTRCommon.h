//
//  ZYTRCommon.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef enum : NSInteger {
    ZYTRSelectionClick_none = 0,
    ZYTRSelectionClick_copy = 101,
    ZYTRSelectionClick_favor = 201,
    ZYTRSelectionClick_tag = 301,
    ZYTRSelectionClick_search = 401,
    ZYTRSelectionClick_speak = 501,
    ZYTRSelectionClick_deletetag = 601,
    ZYTRSelectionClick_konwledge = 701,
}ZYTRSelectionClickType;

#define iPhoneX_zytr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define RGB(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

#define ZYTextLocal(a) NSLocalizedStringFromTable(a, @"zytext", @"")

///安全释放
#define ZYCFSAFERELEASE(a)\
do {\
if(a) {\
CFRelease(a);\
a = NULL;\
}\
} while(0);

///安全赋值
#define ZYCFSAFESETVALUEA(a,b)\
do {\
ZYCFSAFERELEASE(b)\
if (a) {\
CFRetain(a);\
b = a;\
}\
} while(0);

typedef struct {
    ///基线纵坐标
    CGFloat baseLineY;
    ///x点横坐标
    CGFloat xCrd;
    ///高度
    CGFloat height;
    ///角标
    NSUInteger index;
}ZYTRPosition;

NS_INLINE ZYTRPosition ZYMakePosition(CGFloat baseLineY,CGFloat xCrd,CGFloat height,NSUInteger index) {
    return (ZYTRPosition){baseLineY,xCrd,height,index};
}


@interface ZYTRCommon : NSObject

#pragma mark 获取frame
CGFloat getCTFramePahtXOffset(CTFrameRef frame);
CGSize getCTFrameSize(CTFrameRef frame);
CGRect getCTLineBounds(CTFrameRef frame,CTLineRef line,CGPoint origin);
CGRect getCTRunBounds(CTFrameRef frame,CTLineRef line,CGPoint origin,CTRunRef run);

#pragma mark 镜像转换
CGRect convertRect(CGRect rect,CGFloat height);

#pragma mark 尺寸修正
// 返回给定点是否在给定尺寸的修正范围内
BOOL rectFixContainsPoint(CGRect rect,CGPoint point);
// 缩短CGRect至指定坐标
CGRect ShortenRectToXCrd(CGRect rect,CGFloat xCrd,BOOL backward);

#pragma mark 空间位置关系
// 返回给定数在所给范围中的相对位置
NSComparisonResult NumBetweenAB(CGFloat num,CGFloat a,CGFloat b);
// 返指给定点在给定尺寸中的竖直位置关系
NSComparisonResult PointInRectV(CGPoint point,CGRect rect);
// 返指给定点在给定尺寸中的水平位置关系
NSComparisonResult PointInRectH(CGPoint point,CGRect rect);
//返回距离指定坐标较近的一侧的坐标值
CGFloat ClosestSide(CGFloat xCrd,CGFloat left,CGFloat right);
#pragma mark 交换
// 交换两个浮点数
void SwapfAB(CGFloat *a,CGFloat *b);
// 交换两个对象
void SwapoAB(id a,id b);


#pragma mark Helper
//
ZYTRPosition MakePosition(CGFloat baseLineY,CGFloat xCrd,CGFloat height,NSUInteger index);

BOOL PositionEqualToPosition(ZYTRPosition p1,ZYTRPosition p2);

BOOL PositionIsNull(ZYTRPosition p);

BOOL PositionIsZero(ZYTRPosition p);

NSComparisonResult ComparePosition(ZYTRPosition p1,ZYTRPosition p2);

// 空范围，{MAXFLOAT,MAXFLOAT}
UIKIT_EXTERN NSRange const NSRangeNull;

UIKIT_EXTERN NSRange const NSRangeZero;

UIKIT_EXTERN ZYTRPosition const PositionZero;

CGRect CGRectFromPosition(ZYTRPosition p,CGFloat width);

NSRange NSMakeRangeBetweenLocation(NSUInteger loc1,NSUInteger loc2);

@end
