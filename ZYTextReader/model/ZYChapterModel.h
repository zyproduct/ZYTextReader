//
//  ZYChapterModel.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZYTRParserConfig;
@interface ZYChapterModel : NSObject <NSCopying, NSCoding>

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *type;
/**页码数组*/
@property (nonatomic, strong) NSArray *pageArr;

/**内容中的分句（range）数组*/
@property (nonatomic, strong) NSArray *sentenceArr;

@property (nonatomic, strong) NSAttributedString *content;

/**小节sectionModel 数组*/
@property (nonatomic, strong) NSArray *sectionsArr;

/**开始页码*/
@property (nonatomic, assign) NSUInteger startPage;

/**原始数据*/
@property (nonatomic, strong) NSDictionary *dataDic;

/**记录该章节是否与当前字体变化相同*/
@property (nonatomic, assign) int fontChange;

/**记录标记区间*/
@property (nonatomic, strong) NSArray *tagRanges;


/**重新计算chapterModel*/
- (ZYChapterModel *)redrawNeededChapterModelWithConfig:(ZYTRParserConfig *)config;

@end
