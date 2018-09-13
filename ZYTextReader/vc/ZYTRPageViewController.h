//
//  ZYTRPageViewController.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZYTRData;
@interface ZYTRPageViewController : UIViewController

@property (nonatomic, strong) ZYTRData *data;

@property (nonatomic, assign) NSInteger chapterIndex;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, assign) BOOL isCover;

+ (CGSize)textViewSize;

- (void)redrawReadView;

- (NSDictionary *)imageInfoPoint:(CGPoint)point;

- (void)readWithRange:(NSRange)range;

- (void)clearRead;

@end
