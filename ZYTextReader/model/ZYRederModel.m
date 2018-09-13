//
//  ZYRederModel.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYRederModel.h"
#import "ZYChapterModel.h"

@implementation ZYRederModel

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.name = self.name;
    one.chapters = self.chapters;
    one.totalPage = self.totalPage;
    return one;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.chapters forKey:@"chapters"];
    [aCoder encodeObject:@(self.totalPage) forKey:@"totalPage"];
    
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    _name = [aDecoder decodeObjectForKey:@"name"];
    _chapters = [aDecoder decodeObjectForKey:@"chapters"];
    _totalPage = [[aDecoder decodeObjectForKey:@"totalPage"] unsignedIntegerValue];
    return self;
}

@end
