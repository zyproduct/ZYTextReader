//
//  NSString+zyPinyin.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/8/1.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "NSString+zyPinyin.h"

@implementation NSString (zyPinyin)

- (BOOL)strIsChinese {
    if (!self.length) {
        return NO;
    }
    NSString *regex = @"[\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

- (NSString *)transformToPinyin {
    if (!self.length) {
        return self;
    }
    NSMutableString *mutableString = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    //mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    [mutableString appendString:@" "];
    return mutableString;
}

@end
