//
//  ZYTextReaderView.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTRParser.h"
#import "UIView+ZYFrame.h"

@interface ZYTextReaderView : UIView

@property (nonatomic, strong) ZYTRData *data;

- (NSDictionary *)imageInfoAtPoint:(CGPoint)point;

@end
