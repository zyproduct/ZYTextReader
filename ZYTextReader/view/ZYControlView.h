//
//  ZYControlView.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/25.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger{
    ZYTRToolBarType_none,
    ZYTRToolBarType_back,
    ZYTRToolBarType_play,
    ZYTRToolBarType_menu,
    ZYTRToolBarType_font,
    ZYTRToolBarType_minusFont,
    ZYTRToolBarType_extendFont,
}ZYTRToolBarType;

@interface ZYControlView : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title toolBarClick:(void(^)(ZYTRToolBarType type))toolBarClick playShow:(BOOL)playShow;

- (void)showControllViewsComplete:(void(^)(void))complete;

- (void)hideControllViewsComplete:(void(^)(void))complete;

@end
