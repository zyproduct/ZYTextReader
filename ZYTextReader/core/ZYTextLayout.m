//
//  ZYTextLayout.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/17.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTextLayout.h"

@implementation ZYTextGlyphWrapper

- (instancetype)initWithIndex:(NSInteger)index startX:(CGFloat)startX endX:(CGFloat)endX {
    if (self = [super init]) {
        _index = index;
        [self configWithStartX:startX endX:endX];
    }
    return self;
}

- (void)configWithStartX:(CGFloat)startX endX:(CGFloat)endX {
    _startX = startX;
    _endX = endX;
}

- (void)configRun:(ZYTextRunWrapper *)run {
    _run = run;
}

- (void)configWithPreviousGlyph:(ZYTextGlyphWrapper *)previousGlyph {
    _previousGlyph = previousGlyph;
    [previousGlyph configWithNextGlyph:self];
}

- (void)configWithNextGlyph:(ZYTextGlyphWrapper *)nextGlyph {
    _nextGlyph = nextGlyph;
}

-(void)configPositionWithBaseLineY:(CGFloat)baseLineY height:(CGFloat)height {
    _startPosition = ZYMakePosition(baseLineY, _startX, height,_index);
    _endPosition = ZYMakePosition(baseLineY, _endX, height,_index + 1);
}

@end


@implementation ZYTextRunWrapper

+ (instancetype)createWithCTRun:(CTRunRef)run {
    ZYTextRunWrapper *runWrapper = [[ZYTextRunWrapper alloc] initWithCTRun:run];
    return runWrapper;
}

- (instancetype)initWithCTRun:(CTRunRef)run {
    if (self = [super init]) {
        ZYCFSAFESETVALUEA(run, _ctRun)
        _runAttributes = (NSDictionary *)CTRunGetAttributes(run);
        CFRange range = CTRunGetStringRange(_ctRun);
        _startIndex = range.location;
        _endIndex = range.location + range.length;
    }
    return self;
}

- (void)configWithCTFrame:(CTFrameRef)frame ctLine:(CTLineRef)line origin:(CGPoint)origin covertHeight:(CGFloat)height {
    _runRect = getCTRunBounds(frame, line, origin, _ctRun);
    _frame = convertRect(_runRect, height);
}

- (void)configPreviousRun:(ZYTextRunWrapper *)previousRun {
    _previousRun = previousRun;
    [previousRun configNextRun:self];
}

- (void)configNextRun:(ZYTextRunWrapper *)nextRun {
    _nextRun = nextRun;
}

- (void)configLine:(ZYTextLineWrapper *)line {
    _line = line;
}

- (void)handleGlyphWithFrame:(CTFrameRef)frame ctLine:(CTLineRef)line origin:(CGPoint)origin {
    
    NSUInteger count = CTRunGetGlyphCount(_ctRun);
    NSMutableArray *tempArr = [NSMutableArray array];
    ZYTextGlyphWrapper *preGlyph = nil;
    CGFloat baseLineY = CGRectGetMaxY(_line.frame);
    CGFloat height = CGRectGetHeight(_line.frame);
    for (int i = 0; i < count; i++) {
        CGFloat offset = getCTFramePahtXOffset(frame);
        NSUInteger index = _startIndex + i;
        CGFloat startX = origin.x + CTLineGetOffsetForStringIndex(line, index, NULL) + offset;
        CGFloat endX = origin.x + CTLineGetOffsetForStringIndex(line, index + 1, NULL) + offset;
        
        if (startX < CGRectGetMinX(_frame)) {
            if (i == 0) {
                startX = CGRectGetMinX(_frame);
            }
        }
        if (endX < startX || endX > CGRectGetMaxX(_frame)) {
            endX = CGRectGetMaxX(_frame);
            if (endX < startX) {
                startX = endX;
            }
        }
        
        ZYTextGlyphWrapper *glyphWrapper = [[ZYTextGlyphWrapper alloc] initWithIndex:index startX:startX endX:endX];
        [glyphWrapper configRun:self];
        [glyphWrapper configWithPreviousGlyph:preGlyph];
        [glyphWrapper configPositionWithBaseLineY:baseLineY height:height];
        preGlyph = glyphWrapper;
        [tempArr addObject:glyphWrapper];
    }
    _glyphs = tempArr.copy;
}

- (void)handleActiveRunWithFrame:(CTFrameRef)frame height:(CGFloat)height{
    
    CGRect deleteBounds = self.runRect;
    if (CGRectEqualToRect(deleteBounds,CGRectNull)) {
        return ;
    }
    _isImage = NO;
    NSDictionary *attributes = self.runAttributes;
    CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];
    if (delegate) {
        NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
        if ([metaDic isKindOfClass:[NSDictionary class]]) {
            _isImage = YES;
            //图片居中显示
            CGSize size = getCTFrameSize(frame);
            CGRect originRunRect = self.runRect;
            CGFloat runOriginY = originRunRect.origin.y;
            if ([[metaDic valueForKey:@"fullScreen"] boolValue]) {
                _isImgFullScreen = YES;
                runOriginY = (height - originRunRect.size.height)/2.0;
            }
            _runRect = CGRectMake((size.width - originRunRect.size.width)/2.0, runOriginY, originRunRect.size.width, originRunRect.size.height);
            _frame = convertRect(_runRect, height);
            deleteBounds = self.runRect;
            _imageRect = deleteBounds;
            _imageName = [metaDic valueForKey:@"name"];
        }
    }
}

- (void)dealloc {
    ZYCFSAFERELEASE(_ctRun);
}

@end

@implementation ZYTextLineWrapper

+ (instancetype)createWithCTLine:(CTLineRef)line {
    ZYTextLineWrapper *lineWrapper = [[ZYTextLineWrapper alloc] initWithCTLine:line];
    return lineWrapper;
}

- (instancetype)initWithCTLine:(CTLineRef)line {
    if (self = [super init]) {
        ZYCFSAFESETVALUEA(line, _ctLine);
        CFRange range = CTLineGetStringRange(line);
        _startIndex = range.location;
        _endIndex = range.location + range.length;
    }
    return self;
}

- (void)configWithCTFrame:(CTFrameRef)frame row:(NSUInteger)row origin:(CGPoint)origin convertHeight:(CGFloat)height {
    _lineOrigin = origin;
    _row = row;
    _lineRect = getCTLineBounds(frame, _ctLine, origin);
    [self configFrame:convertRect(_lineRect, height)];
}

- (void)configFrame:(CGRect)frame {
    _frame = frame;
}

- (void)configRunsWithCTFrame:(CTFrameRef)frame convertHeight:(CGFloat)height {
    CFArrayRef runs = CTLineGetGlyphRuns(_ctLine);
    NSUInteger count = CFArrayGetCount(runs);
    NSMutableArray *runsA = [NSMutableArray array];
    ZYTextRunWrapper *preRun = nil;
    for (int i = 0; i < count; i++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        ZYTextRunWrapper *runWrap = [ZYTextRunWrapper createWithCTRun:run];
        [runWrap configWithCTFrame:frame ctLine:_ctLine origin:_lineOrigin covertHeight:height];
        [runWrap handleActiveRunWithFrame:frame height:height];
        if (runWrap.isImage) {
            self.hasImage = YES;
            //图片修正line的位置
            CGRect runRect = runWrap.runRect;
            _lineOrigin = runRect.origin;
            _lineRect = runRect;
            _frame = convertRect(_lineRect, height);
        }
        [runWrap configLine:self];
        [runWrap handleGlyphWithFrame:frame ctLine:_ctLine origin:_lineOrigin];
        [runWrap configPreviousRun:preRun];
        preRun = runWrap;
        [runsA addObject:runWrap];
    }
    _runs = runsA.copy;
}

- (void)configPreviousLine:(ZYTextLineWrapper *)previousLine {
    _previousLine = previousLine;
    [previousLine configNextLine:self];
}

- (void)configNextLine:(ZYTextLineWrapper *)nextLine {
    _nextLine = nextLine;
}

-(void)configEndIndex:(NSUInteger)endIndex {
    _endIndex = endIndex;
}

- (void)dealloc {
    ZYCFSAFERELEASE(_ctLine);
}

@end

#pragma mark Layout

@implementation ZYTextLayout

+ (instancetype)layoutWithFrame:(CTFrameRef)frame convertHeight:(CGFloat)height {
    ZYTextLayout *layout = [[ZYTextLayout alloc] initWithCTFrame:frame convertHeight:height];
    return layout;
}

- (instancetype)initWithCTFrame:(CTFrameRef)frame convertHeight:(CGFloat)height {
    if (self = [super init]) {
        CFArrayRef lineArr = CTFrameGetLines(frame);
        NSUInteger lineCount = CFArrayGetCount(lineArr);
        CGPoint origins[lineCount];
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
        ZYTextLineWrapper *preLine = nil;
        NSMutableArray *lineA = [NSMutableArray array];
        NSMutableArray *imageArr = [NSMutableArray array];
        for (int i = 0; i < lineCount; i++) {
            @autoreleasepool {
                CTLineRef line = CFArrayGetValueAtIndex(lineArr, i);
                ZYTextLineWrapper *lineWarp = [ZYTextLineWrapper createWithCTLine:line];
                [lineWarp configWithCTFrame:frame row:i origin:origins[i] convertHeight:height];
                [lineWarp configRunsWithCTFrame:frame convertHeight:height];
                if (lineWarp.hasImage) {
                    for (ZYTextRunWrapper *runWarp in lineWarp.runs) {
                        if (runWarp.isImage) {
                            [imageArr addObject:runWarp];
                        }
                    }
                }
                [lineWarp configPreviousLine:preLine];
                preLine = lineWarp;
                [lineA addObject:lineWarp];
            }
        }
        _lines = lineA.copy;
        _imgArr = imageArr.copy;
        ZYTextGlyphWrapper * lastGlyph = [self lastGlyphWrapper];
        NSUInteger lastIndex = lastGlyph.index;
        [lastGlyph.run.line configEndIndex:lastIndex + 1];
        _maxLoc = lastIndex;
    }
    return self;
}

-(ZYTextGlyphWrapper *)lastGlyphWrapper {
    if (!_lines.count) {
        return nil;
    }
    ZYTextGlyphWrapper * glyph = nil;
    ZYTextLineWrapper * line = _lines.lastObject;
    do {
        if (!line.runs.count) {
            line = line.previousLine;
            continue;
        }
        ZYTextRunWrapper * run = line.runs.lastObject;
        do {
            if (!run.glyphs.count) {
                run = run.previousRun;
                continue;
            }
            glyph = run.glyphs.lastObject;
        } while (run && !glyph);
        line = line.previousLine;
    } while (line && !glyph);
    return glyph;
}

#pragma mark LocationMethod

- (ZYTextGlyphWrapper *)glyphAtPoint:(CGPoint)point {
    ZYTextRunWrapper * run = [self runAtPoint:point];
    if (!run) {
        return nil;
    }
    __block ZYTextGlyphWrapper * glyph = nil;
    [self binarySearchInContainer:run.glyphs condition:^NSComparisonResult(ZYTextGlyphWrapper * obj, NSUInteger currentIdx, BOOL *stop) {
        NSComparisonResult result = NumBetweenAB(point.x, obj.startX, obj.endX);
        if (result == NSOrderedSame) {
            glyph = obj;
        }
        return result;
    }];
    return glyph;
}

- (ZYTextGlyphWrapper *)glyphAtLocation:(NSUInteger)location {
    ZYTextRunWrapper * run = [self runAtLocation:location];
    if (!run) {
        return nil;
    }
    NSUInteger idx = location - run.startIndex;
    if (idx >= run.glyphs.count) {
        return nil;
    }
    return run.glyphs[idx];
}

- (ZYTextRunWrapper *)runAtPoint:(CGPoint)point {
    ZYTextLineWrapper * line = [self lineAtPoint:point];
    if (!line) {
        return nil;
    }
    __block ZYTextRunWrapper * run = nil;
    [self binarySearchInContainer:line.runs condition:^NSComparisonResult(ZYTextRunWrapper * obj, NSUInteger currentIdx, BOOL *stop) {
        if (rectFixContainsPoint(obj.frame, point)) {
            run = obj;
            return NSOrderedSame;
        } else {
            return NumBetweenAB(point.x, CGRectGetMinX(obj.frame), CGRectGetMaxX(obj.frame));
        }
    }];
    return run;
}

- (ZYTextRunWrapper *)runAtLocation:(NSUInteger)location {
    ZYTextLineWrapper * line = [self lineAtLocation:location];
    if (!line) {
        return nil;
    }
    __block ZYTextRunWrapper * run = nil;
    [self binarySearchInContainer:line.runs condition:^NSComparisonResult(ZYTextRunWrapper * obj, NSUInteger currentIdx, BOOL *stop) {
        if (obj.startIndex <= location && obj.endIndex > location) {
            run = obj;
            return NSOrderedSame;
        } else if (obj.startIndex > location) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return run;
}

- (ZYTextLineWrapper *)lineAtPoint:(CGPoint)point {
    __block ZYTextLineWrapper *line = nil;
    [self binarySearchInContainer:self.lines condition:^NSComparisonResult(ZYTextLineWrapper *obj, NSUInteger currentIdx, BOOL *stop) {
        if (rectFixContainsPoint(obj.frame, point)) {
            line = obj;
            return NSOrderedSame;
        }else {
            NSComparisonResult result = PointInRectV(point, obj.frame);
            if (result == NSOrderedSame) {
                return PointInRectH(point, obj.frame);
            } else {
                return result;
            }
        }
    }];
    return line;
}

- (ZYTextLineWrapper *)lineAtLocation:(NSUInteger)locaiton {
    if (locaiton > _maxLoc) {
        return nil;
    }
    __block ZYTextLineWrapper * line = nil;
    [self binarySearchInContainer:self.lines condition:^NSComparisonResult(ZYTextLineWrapper * obj, NSUInteger currentIdx, BOOL *stop) {
        if (obj.startIndex <= locaiton && obj.endIndex > locaiton) {
            line = obj;
            return NSOrderedSame;
        } else if (obj.startIndex > locaiton) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return line;
}

- (CGFloat)xCrdAtLocation:(NSUInteger)loc {
    ZYTextGlyphWrapper * glyph = [self glyphAtLocation:loc];
    if (!glyph) {
        return MAXFLOAT;
    }
    return glyph.startX;
}

- (CGFloat)xCrdAtPoint:(CGPoint)point {
    ZYTextGlyphWrapper * glyph = [self glyphAtPoint:point];
    if (!glyph) {
        return MAXFLOAT;
    }
    return ClosestSide(point.x, glyph.startX, glyph.endX);
}

- (NSArray *)lineRectsAtRanges:(NSRange)range textHeight:(CGFloat)height {
    NSUInteger locationA = range.location;
    NSUInteger locationB = range.location + (range.length - 1);
    if (locationB > _maxLoc + 1) {
        return @[];
    }
    if (locationA > locationB) {
        return @[];
    }
    CGFloat startXCrd = [self xCrdAtLocation:locationA];
    CGFloat endXCrd = [self glyphAtLocation:locationB].endX;
    ZYTextLineWrapper * startLine = [self lineAtLocation:locationA];
    ZYTextLineWrapper * endLine = [self lineAtLocation:locationB];
    if (!startLine || !endLine || startXCrd == MAXFLOAT || endXCrd == MAXFLOAT) {///参数不合法
        return @[];
    }
    if (startLine.startIndex > endLine.startIndex) {///参数不合法
        SwapoAB(startLine, endLine);
    }
    if ([startLine isEqual:endLine]) {///同一Line中
        CGRect r = [self rectInLine:startLine fromX1:startXCrd toX2:endXCrd];
        return @[[NSValue valueWithCGRect:r]];
    }
    ///不同行
    NSMutableArray * rects = @[].mutableCopy;
    [rects addObjectsFromArray:[self rectsInLine:startLine xCrd:startXCrd backward:YES]];
    while (![startLine.nextLine isEqual:endLine]) {
        startLine = startLine.nextLine;
        [rects addObjectsFromArray:[self rectsInLine:startLine]];
    }
    [rects addObjectsFromArray:[self rectsInLine:endLine xCrd:endXCrd backward:NO]];
    return rects;
}
/**
 返回range范围内的bottom点集合
 [  {
    "start":""
    "end"  :""
    }
 ]
 */
- (NSArray *)linePointsAtRanges:(NSRange)range textHeight:(CGFloat)height {
    NSUInteger locationA = range.location;
    NSUInteger locationB = range.location + (range.length - 1);
    if (locationB > _maxLoc + 1) {
        return @[];
    }
    if (locationA >= locationB) {
        return @[];
    }
    CGFloat startXCrd = [self xCrdAtLocation:locationA];
    CGFloat endXCrd = [self glyphAtLocation:locationB].endX;
    ZYTextLineWrapper * startLine = [self lineAtLocation:locationA];
    ZYTextLineWrapper * endLine = [self lineAtLocation:locationB];
    if (!startLine || !endLine || startXCrd == MAXFLOAT || endXCrd == MAXFLOAT) {///参数不合法
        return @[];
    }
    if (startLine.startIndex > endLine.startIndex) {///参数不合法
        SwapoAB(startLine, endLine);
    }
    if ([startLine isEqual:endLine]) {///同一Line中
        CGRect r = [self rectInLine:startLine fromX1:startXCrd toX2:endXCrd];
        r = convertRect(r, height);
        return @[[self bottomPointInfoWithRect:r]];
    }
    ///不同行
    NSMutableArray * rects = @[].mutableCopy;
    [rects addObjectsFromArray:[self rectsInLine:startLine xCrd:startXCrd backward:YES]];
    while (![startLine.nextLine isEqual:endLine]) {
        startLine = startLine.nextLine;
        [rects addObjectsFromArray:[self rectsInLine:startLine]];
    }
    [rects addObjectsFromArray:[self rectsInLine:endLine xCrd:endXCrd backward:NO]];
    NSMutableArray *pinfoArr = @[].mutableCopy;
    [rects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rectV = [(NSValue *)obj CGRectValue];
        rectV = convertRect(rectV, height);
        NSDictionary *pInfo = [self bottomPointInfoWithRect:rectV];
        [pinfoArr addObject:pInfo];
    }];
    return pinfoArr;
}

- (NSDictionary *)bottomPointInfoWithRect:(CGRect)rect {
    CGFloat xStart = rect.origin.x;
    CGFloat xEnd = rect.origin.x + rect.size.width;
    CGFloat Y = rect.origin.y - 2;
    return @{@"startP": NSStringFromCGPoint(CGPointMake(xStart, Y)), @"endP":NSStringFromCGPoint(CGPointMake(xEnd, Y))};
}

- (NSArray *)selectedRectsBetweenLocationA:(NSUInteger)locationA andLocationB:(NSUInteger)locationB {
    if (locationB > _maxLoc + 1) {
        return @[];
    }
    if (locationA >= locationB) {
        return @[];
    }
    locationB --;//函数出入的是不包含的locationB，所以自减至包含位置
    
    CGFloat startXCrd = [self xCrdAtLocation:locationA];
    CGFloat endXCrd = [self glyphAtLocation:locationB].endX;
    ZYTextLineWrapper * startLine = [self lineAtLocation:locationA];
    ZYTextLineWrapper * endLine = [self lineAtLocation:locationB];
    
    return [self rectsInLayoutWithStartLine:startLine startXCrd:startXCrd endLine:endLine endXCrd:endXCrd];
}

//返回任意两个Run直接介于起始终止坐标之间的所有字形矩阵尺寸数组
- (NSArray *)rectsInLayoutWithStartLine:(ZYTextLineWrapper *)startLine startXCrd:(CGFloat)startXCrd endLine:(ZYTextLineWrapper *)endLine endXCrd:(CGFloat)endXCrd {
    if (!startLine || !endLine || startXCrd == MAXFLOAT || endXCrd == MAXFLOAT) {///参数不合法
        return @[];
    }
    if (startLine.startIndex > endLine.startIndex) {///参数不合法
        SwapoAB(startLine, endLine);
    }
    if ([startLine isEqual:endLine]) {///同一Line中
        CGRect r = [self rectInLine:startLine fromX1:startXCrd toX2:endXCrd];
        return RectArray(r);
    }
    ///不同行
    NSMutableArray * rects = @[].mutableCopy;
    [rects addObjectsFromArray:[self rectsInLine:startLine xCrd:startXCrd backward:YES]];
    while (![startLine.nextLine isEqual:endLine]) {
        startLine = startLine.nextLine;
        [rects addObjectsFromArray:[self rectsInLine:startLine]];
    }
    [rects addObjectsFromArray:[self rectsInLine:endLine xCrd:endXCrd backward:NO]];
    return rects;
}

/**
 根据指定条件返回对应Line中xCrd及相应模式对应的字形矩阵尺寸数组
 
 @param line 指定位置的CTLine
 @param xCrd 指定位置的横坐标
 @param backward 是否为向后模式
 @return 符合条件的字形矩阵尺寸数组
 */
- (NSArray *)rectsInLine:(ZYTextLineWrapper *)line xCrd:(CGFloat)xCrd backward:(BOOL)backward {
    if (!line || xCrd == MAXFLOAT) {
        return @[];
    }
    CGFloat x2;
    if (backward) {
        x2 = line.runs.lastObject.glyphs.lastObject.endX;
    } else {
        x2 = line.runs.firstObject.glyphs.firstObject.startX;
    }
    CGRect r = [self rectInLine:line fromX1:xCrd toX2:x2];
    return RectArray(r);
}

- (NSArray *)rectsInLine:(ZYTextLineWrapper *)line {
    if (!line || !line.runs.count) {
        return @[];
    }
    NSValue * v = [NSValue valueWithCGRect:line.frame];
    return @[v];
}

- (CGRect)rectInLine:(ZYTextLineWrapper *)line fromX1:(CGFloat)x1 toX2:(CGFloat)x2 {
    if (x1 == x2) {
        return CGRectZero;
    }
    if (x1 > x2) {
        SwapfAB(&x1, &x2);
    }
    CGRect rect = line.frame;
    if (x1 < CGRectGetMinX(rect)) {
        x1 = CGRectGetMinX(rect);
    }
    if (x2 > CGRectGetMaxX(rect)) {
        x2 = CGRectGetMaxX(rect);
    }
    rect = ShortenRectToXCrd(rect, x1, YES);
    rect = ShortenRectToXCrd(rect, x2, NO);
    return rect;
}

#pragma mark --- 获取点的位置返回角标 ---
- (NSUInteger)locFromPoint:(CGPoint)point {
    ZYTextGlyphWrapper * glyph = [self glyphAtPoint:point];
    if (!glyph) {
        return NSNotFound;
    }
    return glyph.index;
}

- (NSUInteger)closestLocFromPoint:(CGPoint)point {
    ZYTextGlyphWrapper * glyph = [self glyphAtPoint:point];
    if (!glyph) {
        return NSNotFound;
    }
    CGFloat xCrd = ClosestSide(point.x, glyph.startX, glyph.endX);
    if (xCrd == glyph.startX) {
        return glyph.index;
    } else {
        return glyph.index + 1;
    }
}

#pragma mark LayoutHelper
static inline NSArray * RectArray(CGRect r) {
    if (CGRectIsEmpty(r)) {
        return nil;
    }
    return @[[NSValue valueWithCGRect:r]];
}

- (void)binarySearchInContainer:(NSArray *)container condition:(NSComparisonResult(^)(id obj,NSUInteger currentIdx,BOOL * stop))condition {
    if (!condition || container.count == 0) {
        return;
    }
    NSUInteger hR = container.count - 1;
    NSUInteger lR = 0;
    NSUInteger mR = 0;
    BOOL stop = NO;
    while (lR <= hR) {
        mR = (hR + lR) / 2;
        NSComparisonResult result = condition(container[mR],mR,&stop);
        if (result == NSOrderedSame || stop == YES) {
            break;
        } else if (result == NSOrderedAscending) {
            if (mR == 0) {
                break;
            } else {
                hR = mR - 1;
            }
        } else {
            if (mR == container.count - 1) {
                break;
            } else {
                lR = mR + 1;
            }
        }
    }
}

- (void)enumerateCTRunUsingBlock:(void(^) (ZYTextRunWrapper *, BOOL ))hander {
    if (!hander || !self.lines.count) {
        return;
    }
    BOOL stop = NO;
    for (int i = 0; i < self.lines.count; i++) {
        ZYTextLineWrapper *line = self.lines[i];
        for (int j = 0; j < line.runs.count; j++) {
            ZYTextRunWrapper *run = line.runs[j];
            if (!stop) {
                hander (run, stop);
            }
        }
    }
}

@end
