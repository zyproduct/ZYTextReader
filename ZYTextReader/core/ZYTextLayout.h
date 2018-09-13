//
//  ZYTextLayout.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/17.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTRCommon.h"

@class ZYTextRunWrapper;
@interface ZYTextGlyphWrapper : NSObject

/**所属run*/
@property (nonatomic, weak, readonly) ZYTextRunWrapper *run;

/**上一个Glyph*/
@property (nonatomic, weak, readonly) ZYTextGlyphWrapper *previousGlyph;

/**下一个Glyph*/
@property (nonatomic, weak, readonly) ZYTextGlyphWrapper *nextGlyph;

/**字形起始X*/
@property (nonatomic, assign, readonly) CGFloat startX;

/**字形结束X*/
@property (nonatomic, assign, readonly) CGFloat endX;

/**字形索引*/
@property (nonatomic, assign, readonly) NSUInteger index;

/**起始位置*/
@property (nonatomic, assign) ZYTRPosition startPosition;

/**结束位置*/
@property (nonatomic, assign) ZYTRPosition endPosition;

@end

@class ZYTextLineWrapper;
@interface ZYTextRunWrapper : NSObject

/**所属line*/
@property (nonatomic, weak, readonly) ZYTextLineWrapper *line;

/**对应 CTRunRef*/
@property (nonatomic, assign, readonly) CTRunRef ctRun;

/**对应系统尺寸*/
@property (nonatomic, assign, readonly) CGRect runRect;

/**对应屏幕尺寸*/
@property (nonatomic, assign, readonly) CGRect frame;

/**上一个run*/
@property (nonatomic, weak, readonly) ZYTextRunWrapper *previousRun;

/**下一个run*/
@property (nonatomic, weak, readonly) ZYTextRunWrapper *nextRun;

/**对应run的Attribute*/
@property (nonatomic, strong, readonly) NSDictionary *runAttributes;

/**起始位置(包含)*/
@property (nonatomic, assign, readonly) NSUInteger startIndex;

/**结束为止(不包含)*/
@property (nonatomic, assign, readonly) NSUInteger endIndex;

/**是否是图片*/
@property (nonatomic, assign, readonly) BOOL isImage;

/**图片是否全屏*/
@property (nonatomic, assign, readonly) BOOL isImgFullScreen;

/**图片名字*/
@property (nonatomic, strong, readonly) NSString *imageName;

/**实际图片rect*/
@property (nonatomic, assign, readonly) CGRect imageRect;

/**包含的Glyphs*/
@property (nonatomic, strong, readonly) NSArray <ZYTextGlyphWrapper *>* glyphs;

@end

@interface ZYTextLineWrapper : NSObject

/*对应 CTLineRef**/
@property (nonatomic, assign, readonly) CTLineRef ctLine;

/**系统 origin*/
@property (nonatomic, assign, readonly) CGPoint lineOrigin;

/**系统尺寸*/
@property (nonatomic, assign, readonly) CGRect lineRect;

/**系统尺寸*/
@property (nonatomic, assign, readonly) CGRect frame;

/**起始位置(包含)*/
@property (nonatomic, assign, readonly) NSUInteger startIndex;

/**结束位置(不包含)*/
@property (nonatomic, assign, readonly) NSUInteger endIndex;

/**上一个line*/
@property (nonatomic, weak, readonly) ZYTextLineWrapper *previousLine;

/**下一个line*/
@property (nonatomic, weak, readonly) ZYTextLineWrapper *nextLine;

/**行数*/
@property (nonatomic, assign, readonly) NSUInteger row;

/**包含的runs*/
@property (nonatomic, strong, readonly) NSArray <ZYTextRunWrapper *>* runs;

/**是否有图片*/
@property (nonatomic, assign) BOOL hasImage;

@end



@interface ZYTextLayout : NSObject

/**最大位置*/
@property (nonatomic, assign, readonly) NSUInteger maxLoc;

/**包含的lines*/
@property (nonatomic, strong, readonly) NSArray <ZYTextLineWrapper *>* lines;

/**包含的图片*/
@property (nonatomic, strong, readonly) NSArray *imgArr;

+ (instancetype)layoutWithFrame:(CTFrameRef)frame convertHeight:(CGFloat)height;
//
- (ZYTextGlyphWrapper *)glyphAtPoint:(CGPoint)point;
- (ZYTextGlyphWrapper *)glyphAtLocation:(NSUInteger)location;
- (ZYTextRunWrapper *)runAtPoint:(CGPoint)point;
- (ZYTextRunWrapper *)runAtLocation:(NSUInteger)location;
- (ZYTextLineWrapper *)lineAtPoint:(CGPoint)point;
- (ZYTextLineWrapper *)lineAtLocation:(NSUInteger)locaiton;
//
-(NSArray *)selectedRectsBetweenLocationA:(NSUInteger)locationA andLocationB:(NSUInteger)locationB;
-(NSUInteger)closestLocFromPoint:(CGPoint)point;
//
- (NSArray *)linePointsAtRanges:(NSRange)range textHeight:(CGFloat)height;
- (NSArray *)lineRectsAtRanges:(NSRange)range textHeight:(CGFloat)height;
@end
