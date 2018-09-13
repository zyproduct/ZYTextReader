//
//  ZYTRTTSCoverView.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/8/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYTRTTSCoverView : UIView

+ (instancetype)showCoverViewWithSuperView:(UIView *)superView stopClick:(void(^)(void))stopClick dismissed:(void(^)(void))dismissed;

@end
