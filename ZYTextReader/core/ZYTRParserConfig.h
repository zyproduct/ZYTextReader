//
//  ZYTRParserConfig.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYTRParserConfig : NSObject <NSCopying, NSCoding>
/**显示的宽*/
@property (nonatomic, assign) CGFloat width;
/**显示的高*/
@property (nonatomic, assign) CGFloat height;
/**默认字体size*/
@property (nonatomic, assign) CGFloat fontSize;
/**行间距*/
@property (nonatomic, assign) CGFloat lineSpace;
/**段间距*/
@property (nonatomic, assign) CGFloat paragraphSpace;
/**首段缩进大小*/
@property (nonatomic, assign) CGFloat firstLineIndentSize;
/**默认字颜色*/
@property (nonatomic, strong) UIColor *textColor;
/**字体size变化因素*/
@property (nonatomic, assign) int fontChange;

@end
