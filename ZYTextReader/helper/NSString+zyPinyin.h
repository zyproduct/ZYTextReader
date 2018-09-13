//
//  NSString+zyPinyin.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/8/1.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (zyPinyin)

- (BOOL)strIsChinese;

- (NSString *)transformToPinyin;

@end
