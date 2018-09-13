//
//  ZYSectionModel.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/8/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZYTRParserConfig;
@interface ZYSectionModel : NSObject 

@property (nonatomic, strong) NSString *name;

/**在整个章节中的起始位置*/
@property (nonatomic, assign) NSUInteger sectionStartLocation;

@property (nonatomic, assign) NSUInteger sectionStartPage;
@end
