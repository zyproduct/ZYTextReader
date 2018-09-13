//
//  ZYTRData.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTextLayout.h"

@interface ZYTRData : NSObject

@property (nonatomic, assign) CTFrameRef ctFrame;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong, readonly) ZYTextLayout *layout;

@property (nonatomic, strong, readonly) NSAttributedString *content;

@property (nonatomic, assign) NSRange contentRange;

@property (nonatomic, strong) NSArray *tagRanges;

- (void)createLayout;
- (void)setContent:(NSAttributedString *)content;

@end
