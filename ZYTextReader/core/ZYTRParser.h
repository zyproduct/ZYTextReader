//
//  ZYTRParser.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYTRData.h"

@class ZYTRParserConfig, ZYRederModel, ZYChapterModel;

@interface ZYTRParser : NSObject

// readerModel
+ (ZYRederModel *)parserDataDic:(NSDictionary *)dataDic config:(ZYTRParserConfig *)config;
// chapterModel
+ (ZYChapterModel *)chapterWithDataDic:(NSDictionary *)dataDict config:(ZYTRParserConfig *)config;
// data
+ (ZYTRData *)dataWithContent:(NSAttributedString *)content config:(ZYTRParserConfig *)config isParaHead:(BOOL)isParaHead;
+ (void)chapterReGetContent:(ZYChapterModel *)chapterM withDataDic:(NSDictionary *)dataDict config:(ZYTRParserConfig *)config;
@end
