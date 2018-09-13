//
//  ZYTRDataBase.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/8/13.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZYTRManager,ZYTRParserConfig;
@interface ZYTRDataBase : NSObject

+ (instancetype)sharedDataBase;

- (void)insertManagerData:(ZYTRManager *)data withKeyId:(NSString *)keyId;

- (void)deleteManagerDataWithKeyId:(NSString *)keyId;

- (void)getManagerDataWithKeyId:(NSString *)keyId finish:(void(^)(ZYTRManager *manager))finishBlock;

- (void)updateManager:(ZYTRManager *)manager withKeyId:(NSString *)keyId;

- (void)updateChapterIndex:(NSUInteger)chapterIndex pageIndex:(NSUInteger)pageIndex withKeyId:(NSString *)keyId;

- (void)closeAndClean;

@end
