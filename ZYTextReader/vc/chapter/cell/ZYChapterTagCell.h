//
//  ZYChapterTagCell.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/9/4.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYChapterTagCell : UITableViewCell

- (void)dispalyContent:(NSString *)content lines:(NSUInteger)lines spLineShow:(BOOL)splineShow;

+ (CGFloat)tagFont;

+ (CGFloat)tagExtraWidth;

+ (CGFloat)topSpace;

+ (CGFloat)bottomSapce;

@end
