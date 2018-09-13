//
//  ZYTRFunctionView.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/8/8.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYTRFunctionView : UIView

@property (nonatomic, strong) NSArray *pointArr;

- (NSArray *)pointArrWithRectArr:(NSArray *)rects fromView:(UIView *)fromeView;

@end
