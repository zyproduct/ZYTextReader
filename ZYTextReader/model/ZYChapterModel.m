//
//  ZYChapterModel.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYChapterModel.h"
#import "ZYTRParser.h"
#import "ZYTRParserConfig.h"
#import "ZYTRCommon.h"
#import "ZYSectionModel.h"

@implementation ZYChapterModel {
    // NSAttributedString *_content;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.name = self.name;
    one.index = self.index;
    one.type = self.type;
    one.pageArr = self.pageArr;
    one.content = self.content;
    one.startPage = self.startPage;
    one.dataDic = self.dataDic;
    one.fontChange = self.fontChange;
    one.tagRanges = self.tagRanges;
    one.sentenceArr = self.sentenceArr;
    one.sectionsArr = self.sectionsArr;
    return one;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:@(self.index) forKey:@"index"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.pageArr forKey:@"pageArr"];
    //[aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:@(self.startPage) forKey:@"startPage"];
    [aCoder encodeObject:self.dataDic forKey:@"dataDic"];
    [aCoder encodeObject:@(self.fontChange) forKey:@"fontChange"];
    [aCoder encodeObject:self.tagRanges forKey:@"tagRanges"];
    //[aCoder encodeObject:self.sentenceArr forKey:@"sentenceArr"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    _name = [aDecoder decodeObjectForKey:@"name"];
    _index = [[aDecoder decodeObjectForKey:@"index"] integerValue];
    _type = [aDecoder decodeObjectForKey:@"type"];
    _pageArr = [aDecoder decodeObjectForKey:@"pageArr"];
    //_content = [aDecoder decodeObjectForKey:@"content"];
    _startPage = [[aDecoder decodeObjectForKey:@"startPage"] unsignedIntegerValue];
    _dataDic = [aDecoder decodeObjectForKey:@"dataDic"];
    _fontChange = [[aDecoder decodeObjectForKey:@"fontChange"] intValue];
    _tagRanges = [aDecoder decodeObjectForKey:@"tagRanges"];
    //_sentenceArr = [aDecoder decodeObjectForKey:@"sentenceArr"];
    return self;
}

- (ZYChapterModel *)redrawNeededChapterModelWithConfig:(ZYTRParserConfig *)config {
    if (self.content.length) {
        ZYChapterModel *chapterM = [ZYTRParser chapterWithDataDic:self.dataDic config:config];//[[ZYChapterModel alloc] init];
        chapterM.fontChange = config.fontChange;
        chapterM.dataDic = self.dataDic;
        // temp
        chapterM.startPage = self.startPage;
        chapterM.tagRanges = self.tagRanges;
        return chapterM;
    }else {
        return self;
    }
}

@end
