//
//  ZYTRDataBase.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/8/13.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRDataBase.h"
#import "FMDB.h"
#import "ZYTRManager.h"

@interface ZYTRDataBase ()

@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation ZYTRDataBase

static ZYTRDataBase *_DBCtl = nil;
+ (instancetype)sharedDataBase {
    if (_DBCtl == nil) {
        _DBCtl = [[ZYTRDataBase alloc] init];
        [_DBCtl initialDataBase];
    }
    return _DBCtl;
}

- (void)closeAndClean {
    [self.queue close];
    _DBCtl = nil;
}

- (void)initialDataBase {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"zyText.sqlite"];
    self.queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *exsistSql = @"create table if not exists zytext (key_id TEXT PRIMARY KEY, reader_data BLOB,  config BLOB, chatper_index TEXT, page_index TEXT)";
        BOOL ret = [db executeUpdate:exsistSql];
        if (!ret) {
            NSLog(@"create table faile");
        }
    }];
//    _db = [FMDatabase databaseWithPath:filePath];
//    [_db open];
}

- (void)insertManagerData:(ZYTRManager *)data withKeyId:(NSString *)keyId {
    if (!keyId.length || !data) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        NSData *readerData = [NSKeyedArchiver archivedDataWithRootObject:data.readerM];
        NSData *configData = [NSKeyedArchiver archivedDataWithRootObject:data.config];
        BOOL ret = [db executeUpdate:@"insert into zytext (key_id,reader_data,config,chatper_index,page_index) values(?,?,?,?,?)",keyId,readerData,configData,@(0).description,@(0).description];
        if (!ret) {
            NSLog(@"--insert faile");
        }
    }];
}

- (void)deleteManagerDataWithKeyId:(NSString *)keyId {
    if (!keyId.length) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL ret = [db executeUpdate:@"delete from zytext where key_id = ?",keyId];
        if (!ret) {
            NSLog(@"delete faile");
        }
    }];
}

- (void)updateManager:(ZYTRManager *)manager withKeyId:(NSString *)keyId {
    if (!manager || !keyId) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        NSData *readerData = [NSKeyedArchiver archivedDataWithRootObject:manager.readerM];
        NSData *configData = [NSKeyedArchiver archivedDataWithRootObject:manager.config];
        BOOL ret = [db executeUpdate:@"update zytext set reader_data = ?,config = ?  where key_id = ?",readerData,configData,keyId];
        if (!ret) {
            NSLog(@"--update faile");
        }
    }];
}

- (void)updateChapterIndex:(NSUInteger)chapterIndex pageIndex:(NSUInteger)pageIndex withKeyId:(NSString *)keyId{
    if (!keyId) {
        return;
    }
    //NSString *sql = [NSString stringWithFormat:@"update zytext set chatper_index = %lu,page_index = %lu  where key_id = %@",(unsigned long)chapterIndex,(unsigned long)pageIndex,keyId];
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL ret = [db executeUpdate:@"UPDATE 'zytext' SET chatper_index = ?, page_index = ? WHERE key_id = ? ",@(chapterIndex).description,@(pageIndex).description,keyId];
        if (!ret) {
            NSLog(@"--update faile");
        }
    }];
}

- (void)getManagerDataWithKeyId:(NSString *)keyId finish:(void(^)(ZYTRManager *manager))finishBlock {
    if (!keyId.length) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"select *from zytext where key_id = ?",keyId];
        if ([set next]) {
            NSData *bookData = [set dataForColumn:@"reader_data"];
            NSData *confiData = [set dataForColumn:@"config"];
            NSUInteger chapterIndex = [[set stringForColumn:@"chatper_index"] integerValue];
            NSUInteger pageIndex = [[set stringForColumn:@"page_index"] integerValue];
            /*    一 、 通过类方法 反归档 与前面插入的方式对应  */
            ZYTRManager *manager = [[ZYTRManager alloc] init];
            ZYRederModel *readerM = [NSKeyedUnarchiver unarchiveObjectWithData:bookData];
            ZYTRParserConfig *config = [NSKeyedUnarchiver unarchiveObjectWithData:confiData];
            manager.readerM = readerM;
            manager.config = config;
            manager.cIndex = chapterIndex;
            manager.pIndex = pageIndex;
            if (finishBlock) finishBlock(manager);
            [set close];
            /*    二 、 通过创建对象 反归档*/
            //      NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:personData];
            //      Person *p = [unarchiver decodeObjectForKey:@"person"];
            //结束反归档
            //      [unarchiver finishDecoding];
            //return manager;
        }else {
            if (finishBlock) finishBlock(nil);
        }
    }];
}
@end
