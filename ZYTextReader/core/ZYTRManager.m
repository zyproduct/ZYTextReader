//
//  ZYTRManager.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/30.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRManager.h"
#import "ZYTRParserConfig.h"
#import "ZYTRParser.h"
#import "ZYRederModel.h"
#import "ZYChapterModel.h"
#import "FMDB.h"

@interface ZYTRManager ()

@property (nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation ZYTRManager

static ZYTRManager* currentManager= nil;

- (instancetype)init {
    if (self = [super init]) {
        self.lock = [NSRecursiveLock new];
        if (currentManager) {
            currentManager = nil;
        }
        currentManager = self;
    }
    return self;
}

+ (void )managerWithDataDic:(NSDictionary *)dataDic config:(ZYTRParserConfig *)config name:(NSString *)name finish:(void(^)(ZYTRManager *manager))finishBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ZYTRManager *manager = [[ZYTRManager alloc] init];
        manager.config = config;
        ZYRederModel *readerM = [ZYTRParser parserDataDic:dataDic config:config];
        readerM.name = name;
        manager.readerM = readerM;
        if(finishBlock) {
            finishBlock(manager);
        }
    });
}

#pragma mark Cache

- (void)cacheInitial {
    
    NSUInteger chapterIndex = self.cIndex;
    if (chapterIndex > (self.readerM.chapters.count-1)) {
        return;
    }
    ZYChapterModel *chapterM = self.readerM.chapters[chapterIndex];
    [ZYTRParser chapterReGetContent:chapterM withDataDic:chapterM.dataDic config:self.config];
    
    ZYRederModel *cReaderM = [self.readerM copy];
    NSArray *chapterArr = [NSArray arrayWithArray:cReaderM.chapters];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (ZYChapterModel *chapterItem in chapterArr) {
            @autoreleasepool {
                NSInteger index = [chapterArr indexOfObject:chapterItem];
                if (index == chapterIndex) {
                    continue;
                }
                [ZYTRParser chapterReGetContent:chapterItem withDataDic:chapterItem.dataDic config:self.config];
            }
        }
        cReaderM.chapters = chapterArr;
        self.readerM = cReaderM;
    });
}


#pragma mark NormalMethod
- (void)dealloc {
}

+ (ZYTRManager *)currentManager {
    return currentManager;
}

+ (void)cleanManager {
    currentManager = nil;
}

- (ZYChapterModel *)chapterMWithChapterIndex:(NSUInteger)chapterIndex {
    if (chapterIndex > (self.readerM.chapters.count-1)) {
        return nil;
    }
    ZYChapterModel *chapterM = self.readerM.chapters[chapterIndex];
    if (chapterM.fontChange != self.config.fontChange) {
        ZYChapterModel *oterhChapter = [chapterM copy];
        oterhChapter = [oterhChapter redrawNeededChapterModelWithConfig:self.config];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.readerM.chapters];
        [arr replaceObjectAtIndex:chapterIndex withObject:oterhChapter];
        self.readerM.chapters = arr;
        chapterM = nil;
        return oterhChapter;
    }else {
        return chapterM;
    }
}

- (void)updateChapterIndex:(NSUInteger)chapterIndex pageIndex:(NSUInteger)pageIndex  {
    self.cIndex = chapterIndex;
    self.pIndex = pageIndex;
}

#pragma mark FontChangeReDraw
- (void)recreateReaderMAsync:(void(^)(void))complete {
    if (self.readerM.chapters) {
        [self asyncOperationData:^(ZYRederModel *readerModel) {
            self.readerM = readerModel;
            if (complete) complete();
            ZYChapterModel *cm = [self.readerM.chapters firstObject];
            NSLog(@"--cfont:[%d] final fontChange---[%d]",self.config.fontChange,cm.fontChange);
            //self.executing = NO;
        }];
    }
}

- (void)asyncOperationData:(void(^)(ZYRederModel *readerModel))complete {
    ZYRederModel *cReaderM = [self.readerM copy];
    ZYTRParserConfig *config = [self.config copy];
    NSArray *chapterArr = [NSArray arrayWithArray:cReaderM.chapters];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //self.executing = YES;
        ZYRederModel *readerM = [[ZYRederModel alloc] init];
        readerM.name = cReaderM.name;
        NSMutableArray *mChapters = [NSMutableArray array];
        NSUInteger startPage = 0;
        for (ZYChapterModel *chapterItem in chapterArr) {
            @autoreleasepool {
                if (config.fontChange != self.config.fontChange) {
                    NSLog(@"--cancel---");
                    return;
                }
                if (chapterItem.fontChange == config.fontChange) {
                    chapterItem.startPage = startPage;
                    [mChapters addObject:chapterItem];
                    startPage += chapterItem.pageArr.count;
                }else {
                    ZYChapterModel *chapterM = [chapterItem redrawNeededChapterModelWithConfig:config];
                    chapterM.startPage = startPage;
                    [mChapters addObject:chapterM];
                    startPage += chapterM.pageArr.count;
                }
            }
        }
        readerM.chapters = mChapters;
        if (complete) complete(readerM);
    });
}

#pragma mark Range Methods

- (ZYChapterModel *)updateChapterTagRangeWithChapterIndex:(NSUInteger)chapterIndex rangeInChapter:(NSRange)range isDelete:(BOOL)isDelete {
    ZYChapterModel *chapterM = [self chapterMWithChapterIndex:chapterIndex];
    if (isDelete) {
        [self deleteTageRange:range inChapter:chapterM];
    }else {
        [self updateTagRanges:range inChapterM:chapterM];
    }
    return chapterM;
}

- (void)deleteTageRange:(NSRange)range inChapter:(ZYChapterModel *)chapterM {
    if (NSEqualRanges(range, NSRangeNull)) {
        return;
    }
    NSUInteger cLoc = range.location;
    NSUInteger cLength = range.location + (range.length - 1);
    if (cLength < cLoc) {
        return;
    }
    
    NSArray *tagRanges = [NSArray array];
    if (chapterM.tagRanges) {
        tagRanges = [chapterM.tagRanges copy];
    }
    NSMutableArray *temRanges = [NSMutableArray arrayWithArray:tagRanges];
    [tagRanges enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange exr = [(NSValue *)obj rangeValue];
        if (NSLocationInRange(cLoc, exr) && NSLocationInRange(cLength, exr)) {
            NSUInteger newFirstLoc = cLoc - exr.location;
            NSUInteger newSecondLoc = exr.location + exr.length - 1 - cLength;
            if (newFirstLoc == 0) { //刚好开头一样 新生成一段
                NSRange newRange = NSMakeRange(cLength, exr.length - range.length);
                [temRanges removeObject:obj];
                if (newRange.length) {
                    [temRanges insertObject:[NSValue valueWithRange:newRange] atIndex:idx];
                }
            }else if (newSecondLoc == 0) { //刚好结尾一样 新生成一段
                NSRange newRange = NSMakeRange(exr.location, exr.length - range.length);
                [temRanges removeObject:obj];
                if (newRange.length) {
                    [temRanges insertObject:[NSValue valueWithRange:newRange] atIndex:idx];
                }
            }else { //新生成两段
                NSRange beforeRange = NSMakeRange(exr.location, newFirstLoc);
                NSRange afterRange = NSMakeRange(cLength+1, newSecondLoc);
                [temRanges removeObject:obj];
                [temRanges insertObject:[NSValue valueWithRange:beforeRange] atIndex:idx];
                [temRanges insertObject:[NSValue valueWithRange:afterRange] atIndex:idx+1];
            }
            *stop = YES;
        }
    }];
    chapterM.tagRanges = temRanges;
}

- (void)updateTagRanges:(NSRange)range inChapterM:(ZYChapterModel *)chapterM {
    if (NSEqualRanges(range, NSRangeNull)) {
        return;
    }
    NSUInteger cLoc = range.location;
    NSUInteger cLength = range.location + (range.length - 1);
    if (cLength < cLoc) {
        return;
    }
    
    NSArray *tagRanges = [NSArray array];
    if (chapterM.tagRanges) {
        tagRanges = [chapterM.tagRanges copy];
    }
    
    NSMutableArray *relationArr = [NSMutableArray array];   //记录跟range相连的索引
    NSMutableArray *temRanges = [NSMutableArray arrayWithArray:tagRanges];
    [tagRanges enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange exr = [(NSValue *)obj rangeValue];
        //NSUInteger exlength = exr.location + (exr.length - 1);
        NSRange exterRange = NSIntersectionRange(exr, range);
        if (!NSEqualRanges(exterRange, NSRangeZero)) {
            NSLog(@"有交集 --exrange -----%@",NSStringFromRange(range));
            [relationArr addObject:@(idx)];
        }else if (exr.location == cLength+1 || exr.location+exr.length == cLoc) { //首尾相连
            NSLog(@"首尾相连 --exrange -----%@",NSStringFromRange(range));
            [relationArr addObject:@(idx)];
        }
    }];
    if (relationArr.count) {
        NSRange newRange = range;
        NSUInteger firstIndex = [relationArr[0] unsignedIntegerValue];
        for (NSNumber *indexN in relationArr) {
            NSValue *exRV = tagRanges[indexN.unsignedIntegerValue];
            NSRange exr = [(NSValue *)exRV rangeValue];
            newRange = NSUnionRange(exr, newRange);
            [temRanges removeObject:exRV];
        }
        [temRanges insertObject:[NSValue valueWithRange:newRange] atIndex:firstIndex];
    }else {
        [temRanges addObject:[NSValue valueWithRange:range]];
    }
    chapterM.tagRanges = temRanges;
}

- (BOOL)currentTagRange:(NSRange)range containsInChapterM:(ZYChapterModel *)chapterM {
    if (NSEqualRanges(range, NSRangeNull)) {
        return NO;
    }
    NSUInteger cLoc = range.location;
    NSUInteger cLength = range.location + (range.length - 1);
    if (cLength < cLoc) {
        return NO;
    }
    BOOL contain = NO;
    for (NSValue *rValue in chapterM.tagRanges) {
        NSRange r = [rValue rangeValue];
        if (NSLocationInRange(cLoc, r) && NSLocationInRange(cLength, r)) {
            contain = YES;
            break;
        }
    }
    return contain;
}

- (NSArray *)tagRangesInChapter:(ZYChapterModel *)chapterM withSubRange:(NSRange)cotentRange {
    if (!chapterM.tagRanges.count) {
        return nil;
    }
    NSUInteger contentLength  = cotentRange.location + (cotentRange.length - 1);
    NSMutableArray *dataTagRanges = [NSMutableArray array];
    [chapterM.tagRanges enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //章节中的选中范围
        NSRange tagRange = [(NSValue *)obj rangeValue];
        NSUInteger tagLength = tagRange.location + (tagRange.length - 1);
        if (tagRange.location >= cotentRange.location && tagRange.location < contentLength) { //起点在当前页
            NSUInteger newLoc = tagRange.location - cotentRange.location;
            NSUInteger newLength = tagLength <= contentLength ? tagRange.length:(cotentRange.length - newLoc);
            NSRange newRange = NSMakeRange(newLoc, newLength);
            [dataTagRanges addObject:[NSValue valueWithRange:newRange]];
        }else if(tagRange.location < cotentRange.location && tagLength > cotentRange.location){
            NSUInteger newLength = tagLength < contentLength ? (tagLength+1 - cotentRange.location):(contentLength+1);
            NSRange newRange = NSMakeRange(0, newLength);
            [dataTagRanges addObject:[NSValue valueWithRange:newRange]];
        }
    }];
    return dataTagRanges;
}

@end
