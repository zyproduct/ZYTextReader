//
//  ZYTRManager.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/30.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZYTRParserConfig,ZYRederModel,ZYChapterModel;
@interface ZYTRManager : NSObject

@property (nonatomic, strong) ZYTRParserConfig *config;

@property (nonatomic, strong) ZYRederModel *readerM;

@property (nonatomic, assign) NSUInteger cIndex;    //初始当前章节索引

@property (nonatomic, assign) NSUInteger pIndex;    //初始当前页数索引（章节内）

//创建一个新的manager
+ (void )managerWithDataDic:(NSDictionary *)dataDic config:(ZYTRParserConfig *)config name:(NSString *)name finish:(void(^)(ZYTRManager *manager))finishBlock;

//获取当前manager
+ (ZYTRManager *)currentManager;

+ (void)cleanManager;

- (ZYChapterModel *)chapterMWithChapterIndex:(NSUInteger)chapterIndex;

- (void)recreateReaderMAsync:(void(^)(void))complete;



/**一个区域内的标记范围数组*/
- (NSArray *)tagRangesInChapter:(ZYChapterModel *)chapterM withSubRange:(NSRange)cotentRange;
/**chpter是否包含当前tagRange*/
- (BOOL)currentTagRange:(NSRange)range containsInChapterM:(ZYChapterModel *)chapterM;
/**更新chapter的tagRanges*/
- (ZYChapterModel *)updateChapterTagRangeWithChapterIndex:(NSUInteger)chapterIndex rangeInChapter:(NSRange)range isDelete:(BOOL)isDelete;

- (void)cacheInitial;
//- (void)updateChapterIndex:(NSUInteger)chapterIndex pageIndex:(NSUInteger)pageIndex;

@end
