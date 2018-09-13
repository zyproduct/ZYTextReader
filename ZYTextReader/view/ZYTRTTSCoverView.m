//
//  ZYTRTTSCoverView.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/8/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRTTSCoverView.h"
#import "Masonry.h"
#import "ZYTRCommon.h"
#import "UIView+ZYFrame.h"

@interface ZYGestureUndoView:UIView
@end

@implementation ZYGestureUndoView
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    return NO;
//}
@end

@interface ZYTRTTSCoverView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) ZYGestureUndoView *bottomView;

@property (nonatomic, copy) void(^stopClickBlock)(void);
@property (nonatomic, copy) void(^dismissBlock)(void);

@end

@implementation ZYTRTTSCoverView {
    BOOL _bottomShow;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]){
        self.bgView = [[UIView alloc] initWithFrame:self.bounds];
        self.bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverTap:)];
        tap.delegate = self;
        [self.bgView addGestureRecognizer:tap];
        [self createUIs];
    }
    return self;
}

+ (instancetype)showCoverViewWithSuperView:(UIView *)superView stopClick:(void(^)(void))stopClick dismissed:(void(^)(void))dismissed {
    if (!superView) {
        return nil;
    }
    ZYTRTTSCoverView *coverView = [[ZYTRTTSCoverView alloc] initWithFrame:superView.bounds];
    coverView.stopClickBlock = stopClick;
    coverView.dismissBlock = dismissed;
    [superView addSubview:coverView];
    return coverView;
}

- (void)createUIs {
    CGFloat bottomH = 80.0f;
    CGFloat bottomOff = 0;
    if (iPhoneX_zytr) {
        bottomOff = 20;
        bottomH += bottomOff;
    }
//    CGFloat btnW = 80;
//    CGFloat btnH = 40;
    self.bottomView = [[ZYGestureUndoView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, bottomH)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:self.bottomView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomView addSubview:btn];
    [btn setTitle:ZYTextLocal(@"endPlay") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.size.mas_equalTo(CGSizeMake(btnW, btnH));
        //make.centerX.mas_equalTo(0);
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_offset(-bottomOff);
    }];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick:(id)sender {
    if (self.stopClickBlock){
        _stopClickBlock();
    }
    __weak typeof(self) wslef = self;
    [self dismissBottomView:^{
        if (wslef.dismissBlock) {
            wslef.dismissBlock();
        }
    }];
}

- (void)coverTap:(id)sender {
    if (_bottomShow) {
        [self dismissBottomView:nil];
    }else {
        [self showBottomView];
    }
}

- (void)showBottomView {
    CGFloat toolH = self.bottomView.frame.size.height;
    _bottomShow = YES;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        [self.bottomView setY:(self.bounds.size.height - toolH)] ;
    } completion:^(BOOL finished) {
        //if (complete) complete();
    }];
}

- (void)dismissBottomView:(void(^)(void))complete {
    _bottomShow = NO;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bgView.backgroundColor = [UIColor clearColor];
        [self.bottomView setY:self.bounds.size.height] ;
    } completion:^(BOOL finished) {
        if (complete) complete();
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_bottomShow) {
        CGPoint point = [touch locationInView:self.bgView];
        CGRect bottomR = self.bottomView.frame;
        if (CGRectContainsPoint(bottomR, point)) {
            return NO;
        }
    }
    return YES;
}

@end
