//
//  ZYTRChapterVC.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/26.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZYRederModel;
@interface ZYTRChapterVC : UIViewController

+ (void)showChapterVCWithReaderM:(ZYRederModel *)readerM parentVC:(UIViewController *)parentVC clickChapter:(void(^)(NSUInteger chapterIndex, NSUInteger pageIndex))clickBlock dismiss:(void(^)(BOOL isChoose))dismissBlock;

@end
