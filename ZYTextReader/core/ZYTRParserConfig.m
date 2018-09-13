//
//  ZYTRParserConfig.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRParserConfig.h"
#import "ZYTRCommon.h"

@implementation ZYTRParserConfig

- (instancetype)init {
    if (self = [super init]) {
        _width = 200.f;
        _fontSize = 16.0f;
        _lineSpace = 8.0f;
        _paragraphSpace = 20.0f;
        _textColor = RGB(108, 108, 108);
        _fontChange = 0;
        _firstLineIndentSize = 25.0f;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:@(self.fontSize) forKey:@"fontSize"];
    [aCoder encodeObject:@(self.lineSpace) forKey:@"lineSpace"];
    [aCoder encodeObject:@(self.paragraphSpace) forKey:@"paragraphSpace"];
    [aCoder encodeObject:@(self.firstLineIndentSize) forKey:@"firstLineIndentSize"];
    [aCoder encodeObject:self.textColor forKey:@"textColor"];
    [aCoder encodeObject:@(self.fontChange) forKey:@"fontChange"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    _fontSize = [[aDecoder decodeObjectForKey:@"fontSize"] floatValue];
    _lineSpace = [[aDecoder decodeObjectForKey:@"lineSpace"] floatValue];
    _paragraphSpace = [[aDecoder decodeObjectForKey:@"paragraphSpace"] floatValue];
    _firstLineIndentSize = [[aDecoder decodeObjectForKey:@"firstLineIndentSize"] floatValue];
    _textColor = [aDecoder decodeObjectForKey:@"textColor"];
    _fontChange = [[aDecoder decodeObjectForKey:@"fontChange"] intValue];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.width = self.width;
    one.height = self.height;
    one.fontSize = self.fontSize;
    one.lineSpace = self.lineSpace;
    one.paragraphSpace = self.paragraphSpace;
    one.firstLineIndentSize = self.firstLineIndentSize;
    one.textColor = self.textColor;
    one.fontChange = self.fontChange;
    return one;
}

@end
