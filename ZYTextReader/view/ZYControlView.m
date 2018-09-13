//
//  ZYControlView.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/25.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYControlView.h"
#import "UIView+ZYFrame.h"
#import "ZYTRCommon.h"
#import "Masonry.h"

@interface ZYControlView ()

@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, copy) void(^toolBarClickBlock) (ZYTRToolBarType type);

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UIButton *fontBtn;
@property (nonatomic, strong) UIButton *menuBtn;

@property (nonatomic, strong) UIView *funcView;
@property (nonatomic, strong) UIView *funcContentView;

@property (nonatomic, assign) BOOL playShow;
@end

@implementation ZYControlView {
    CGFloat _originToolH;
    CGFloat _funcShow;
    ZYTRToolBarType _currentType;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title toolBarClick:(void(^)(ZYTRToolBarType type))toolBarClick playShow:(BOOL)playShow {
    if (self = [super initWithFrame:frame]) {
        self.titleStr = title;
        self.toolBarClickBlock = toolBarClick;
        self.playShow = playShow;
        [self createSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews {
    CGFloat topH = 70.0f;
    CGFloat toolBarH = 70.0f;
    CGFloat bottomOff = 0;
    CGFloat funcH = 60.0f;
    if (iPhoneX_zytr) {
        topH += 25;
        bottomOff = 20.0;
        toolBarH += bottomOff;
    }
    _originToolH = toolBarH;
    [self createTopView:topH];
    [self createToolBarView:toolBarH bottomOff:bottomOff funcH:funcH];
}

- (void)createTopView:(CGFloat)topH {
    CGFloat backLength = 20;
    CGFloat labelW = 200;
    CGFloat labelH = 25.0f;
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, -topH, self.bounds.size.width, topH)];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.topView];
    self.topView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.topView.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.topView.layer.shadowOpacity = 0.3;
    
    UIImageView *backImgv = [[UIImageView alloc] initWithFrame:CGRectZero];
    backImgv.image = [UIImage imageNamed:@"back.png"];
    [self.topView addSubview:backImgv];
    [backImgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(backLength, backLength));
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(-15);
    }];
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.topView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(backLength+20, backLength+10));
        make.center.mas_equalTo(backImgv);
    }];
    [self.backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(labelW, labelH));
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(backImgv);
    }];
    self.titleLabel.font = [UIFont systemFontOfSize:20.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = self.titleStr;
}

- (void)createToolBarView:(CGFloat)toolBarH bottomOff:(CGFloat)bottomOff funcH:(CGFloat)funcH {
    __weak typeof(self) wslef = self;
    self.toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, toolBarH)];
    self.toolbarView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.toolbarView];
    self.toolbarView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.toolbarView.layer.shadowOffset = CGSizeMake(0, -0.5);
    self.toolbarView.layer.shadowOpacity = 0.3;
    
    self.funcView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.toolbarView.width, funcH)];
    [self.toolbarView addSubview:self.funcView];
    self.funcView.backgroundColor = [UIColor whiteColor];
    
    self.funcContentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.funcView addSubview:self.funcContentView];
    [self.funcContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectZero];
    topBorder.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    [self.funcView addSubview:topBorder];
    [topBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    UIView *toolBgView = [[UIView alloc] initWithFrame:CGRectZero];
    toolBgView.backgroundColor = [UIColor whiteColor];
    [self.toolbarView addSubview:toolBgView];
    [toolBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(toolBarH-1);
    }];
    self.fontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fontBtn setTitle:@"A" forState:UIControlStateNormal];
    [self.fontBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.fontBtn.titleLabel.font = [UIFont boldSystemFontOfSize:25];
    [toolBgView addSubview:self.fontBtn];
    [self.fontBtn addTarget:self action:@selector(fontClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.fontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(wslef).multipliedBy(0.25);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-bottomOff);
        make.right.mas_equalTo(0);
    }];
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBgView addSubview:self.menuBtn];
    [self.menuBtn setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [self.menuBtn addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(wslef).multipliedBy(0.25);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-bottomOff);
        make.left.mas_equalTo(0);
    }];
}

- (void)showControllViewsComplete:(void(^)(void))complete {
    self.hidden = NO;
    CGFloat toolH = self.toolbarView.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.topView.y = 0;
        self.toolbarView.y = self.bounds.size.height - toolH;
    } completion:^(BOOL finished) {
        if (complete) complete();
    }];
}

- (void)hideControllViewsComplete:(void(^)(void))complete {
    CGFloat topH = self.topView.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.topView.y = -topH;
        self.toolbarView.y = self.bounds.size.height;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.toolbarView.height = self->_originToolH;
        self->_funcShow = NO;
        [self cleanFuncContent];
        self->_currentType = ZYTRToolBarType_none;
        if (complete) complete();
    }];
}

- (void)showFuncViewWithType:(ZYTRToolBarType)type {
    if (type == _currentType) return;
    
    if (type == ZYTRToolBarType_font) {
        _currentType = ZYTRToolBarType_font;
        [self showFontChooseFunc];
    }
    if (!_funcShow) {
        _funcShow = YES;
        CGFloat toolH = self.toolbarView.height;
        CGFloat funcH = self.funcView.height;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.funcView.y = -funcH;
        } completion:^(BOOL finished) {
            self.funcView.y = 0;
            self.toolbarView.height += (funcH-1);
            self.toolbarView.y = self.bounds.size.height - toolH - (funcH-1);
        }];
    }
}

- (void)showFontChooseFunc {
    CGFloat btnW = 60.0;
    CGFloat btnH = 35.0;
    CGFloat hpadding = 45.0;
    UIButton *minusfontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.funcContentView addSubview:minusfontBtn];
    [minusfontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(btnW, btnH));
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(hpadding);
    }];
    minusfontBtn.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor;
    minusfontBtn.layer.borderWidth = 1.0;
    minusfontBtn.layer.cornerRadius = 5;
    [minusfontBtn setTitle:@"A-" forState:UIControlStateNormal];
    [minusfontBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
    minusfontBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [minusfontBtn addTarget:self action:@selector(minusClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *extendfontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.funcContentView addSubview:extendfontBtn];
    [extendfontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(btnW, btnH));
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-hpadding);
    }];
    extendfontBtn.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor;
    extendfontBtn.layer.borderWidth = 1.0;
    extendfontBtn.layer.cornerRadius = 5;
    [extendfontBtn setTitle:@"A+" forState:UIControlStateNormal];
    [extendfontBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
    extendfontBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [extendfontBtn addTarget:self action:@selector(extendClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cleanFuncContent {
    for (UIView *subV in self.funcContentView.subviews) {
        [subV removeFromSuperview];
    }
}

#pragma mark Actions

- (void)backClick:(id)sender {
    if (self.toolBarClickBlock) _toolBarClickBlock(ZYTRToolBarType_back);
}

- (void)playClick:(id)sender {
    if (self.toolBarClickBlock) _toolBarClickBlock(ZYTRToolBarType_play);
}

- (void)fontClick:(id)sender {
    [self showFuncViewWithType:ZYTRToolBarType_font];
}

- (void)minusClick:(id)sender {
    if (self.toolBarClickBlock) _toolBarClickBlock(ZYTRToolBarType_minusFont);
}

- (void)extendClick:(id)sender {
    if (self.toolBarClickBlock) _toolBarClickBlock(ZYTRToolBarType_extendFont);
}

- (void)menuClick:(id)sender {
    if (self.toolBarClickBlock) _toolBarClickBlock(ZYTRToolBarType_menu);
}

@end
