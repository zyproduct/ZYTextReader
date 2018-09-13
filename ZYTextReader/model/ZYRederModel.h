//
//  ZYRederModel.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZYChapterModel,ZYTRParserConfig;
@interface ZYRederModel : NSObject <NSCopying,NSCoding>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSArray *chapters;

@property (nonatomic, assign) NSUInteger totalPage;

@end
