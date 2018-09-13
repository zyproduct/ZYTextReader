//
//  ZYTRSelectionView.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/19.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRSelectionView.h"

@interface ZYTextGrabber : UIView

@property (nonatomic ,assign) BOOL startGrabber;
@property (nonatomic, strong) UIView *dot;

@property (nonatomic ,assign) BOOL needsResetPot;

@end

@implementation ZYTextGrabber
- (instancetype)initWithPosition:(ZYTRPosition)position {
    if (self = [super init]) {
        self.frame = CGRectFromPosition(position, 1);
        self.backgroundColor = [UIColor colorWithRed:30 / 255.0 green:144 / 255.0 blue:1 alpha:1];
        _needsResetPot = YES;
        self.dot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.dot.backgroundColor = self.backgroundColor;
        self.dot.layer.cornerRadius = 5;
        [self addSubview:self.dot];
    }
    return self;
}

- (void)moveToPosition:(ZYTRPosition)position {
    CGRect frame = self.frame;
    CGFloat oB = CGRectGetMaxY(frame);
    CGFloat oX = CGRectGetMinX(frame);
    CGFloat oH = CGRectGetHeight(frame);
    ZYTRPosition oP = MakePosition(oB, oX, oH,0);
    if (!PositionEqualToPosition(position, oP)) {
        frame.origin.y = position.baseLineY - position.height;
        frame.origin.x = position.xCrd;
        frame.size.height = position.height;
        self.frame = frame;
        _needsResetPot = YES;
        [self updateDot];
    }
}

- (void)updateDot {
    if (_needsResetPot) {
        if (self.startGrabber) {
            self.dot.center = CGPointMake(0, 0);
        } else {
            self.dot.center = CGPointMake(1, self.bounds.size.height);
        }
        //self.touchDotView.center = self.dot.center;
        _needsResetPot = NO;
    }
}

@end

#pragma mark SelectionView
@interface ZYTRSelectionView ()

@property (nonatomic ,strong) UIView * maskViewsContainer;

@property (nonatomic ,strong) NSMutableArray * selectedRects;

@property (nonatomic ,strong) ZYTextGrabber * startGrabber;
@property (nonatomic, strong) UIView *startTouchDot;

@property (nonatomic ,strong) ZYTextGrabber * endGrabber;
@property (nonatomic, strong) UIView *endTouchDot;

@end

@implementation ZYTRSelectionView

- (BOOL)updateGrabberWithStartPosition:(ZYTRPosition)startP endPosition:(ZYTRPosition)endP grabberShow:(BOOL)grabberShow {
    if (PositionIsNull(startP) || PositionIsNull(endP)) {
        return NO;
    }
    if (PositionIsZero(startP) || PositionIsZero(endP)) {
        [self hideGrabber];
        return YES;
    }
    if (ComparePosition(startP, endP) == NSOrderedDescending) {
        ZYTRPosition temp = startP;
        startP = endP;
        endP = temp;
    }
//    [self.caret hideCaret];
    if (grabberShow) {
        [self showGrabber];
    }else {
        [self hideGrabber];
    }
    [self.startGrabber moveToPosition:startP];
    [self.endGrabber moveToPosition:endP];
    [self updateTouchDot];
    return YES;
}

- (void)updateTouchDot {
    CGPoint startCenter = [_startGrabber convertPoint:self.startGrabber.dot.center toView:self];
    self.startTouchDot.center = startCenter;
    CGPoint endCenter = [_endGrabber convertPoint:self.endGrabber.dot.center toView:self];
    self.endTouchDot.center = endCenter;
}

- (BOOL)updateSelectedRects:(NSArray *)rects isTTs:(BOOL)isTTs{
//    [self hideSelectMenu];
    [self.maskViewsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];///移除全部遮罩
    CGRect box = self.maskViewsContainer.bounds;
    __block BOOL updated = NO;
    NSMutableArray * selectedRects = @[].mutableCopy;
    [rects enumerateObjectsUsingBlock:^(NSValue * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rect = [obj CGRectValue];
        if (CGRectIsEmpty(rect) || CGRectIsEmpty(CGRectIntersection(rect, box))) {
            return ;
        }
        if (!updated) {
            updated = YES;
        }
        [selectedRects addObject:obj];
        UIView * mask = [[UIView alloc] initWithFrame:rect];
        UIColor *selectColor = [UIColor colorWithRed:30 / 255.0 green:144 / 255.0 blue:1 alpha:0.25];
        if (isTTs) {
            selectColor = [[UIColor orangeColor] colorWithAlphaComponent:0.15];
        }
        mask.backgroundColor = selectColor;
        [self.maskViewsContainer addSubview:mask];
    }];
    if (updated) {
        self.selectedRects = selectedRects;
    }
    return updated;
}

- (BOOL)updateSelectedRects:(NSArray *)rects startGrabberPosition:(ZYTRPosition)startP endGrabberPosition:(ZYTRPosition)endP grabberShow:(BOOL)grabberShow isTTs:(BOOL)isTTs {
    BOOL updated = [self updateGrabberWithStartPosition:startP endPosition:endP grabberShow:grabberShow];
    if (updated) {
        updated |= [self updateSelectedRects:rects isTTs:isTTs];
    }
    return updated;
}

- (void)showGrabber {
    [self updateTouchDot];
    self.startGrabber.hidden = NO;
    self.endGrabber.hidden = NO;
    self.startTouchDot.hidden = NO;
    self.endTouchDot.hidden = NO;
}

- (void)hideGrabber {
    self.startGrabber.hidden = YES;
    self.endGrabber.hidden = YES;
    self.startTouchDot.hidden = YES;
    self.endTouchDot.hidden = YES;
}

- (BOOL)grabberIsHidden {
    return (self.startGrabber.hidden && self.endGrabber.hidden);
}

- (void)startDotPan:(UIPanGestureRecognizer *)pan {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectionViewDotPanMove:isStartGabber:)]) {
        [_delegate selectionViewDotPanMove:pan isStartGabber:YES];
    }
}

- (void)endDotPan:(UIPanGestureRecognizer *)pan {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectionViewDotPanMove:isStartGabber:)]) {
        [_delegate selectionViewDotPanMove:pan isStartGabber:NO];
    }
}

#pragma mark Menue

- (void)showMenueInRect:(CGRect)rect cidianShow:(BOOL)ciDianShow isDeleteTag:(BOOL)isDeletetag {
    
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    NSMutableArray * actions = @[].mutableCopy;
    
    [actions addObject:[[UIMenuItem alloc] initWithTitle:ZYTextLocal(@"copy") action:@selector(zytrCopy:)]];
    //[actions addObject:[[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(zytrFavor:)]];
    if (isDeletetag) {
        [actions addObject:[[UIMenuItem alloc] initWithTitle:ZYTextLocal(@"delete") action:@selector(zytrDeleteTag:)]];
    }else {
        [actions addObject:[[UIMenuItem alloc] initWithTitle:ZYTextLocal(@"tag") action:@selector(zytrTag:)]];
    }
    if (ciDianShow) {
        [actions addObject:[[UIMenuItem alloc] initWithTitle:ZYTextLocal(@"cidian") action:@selector(zytrSearch:)]];
    }
    //[actions addObject:[[UIMenuItem alloc] initWithTitle:ZYTextLocal(@"baike") action:@selector(zytrKonwledge:)]];
    menu.menuItems = actions;
    [menu setTargetRect:rect inView:self];
    [menu setMenuVisible:YES animated:YES];
    
}

- (void)showMenue:(BOOL)ciDianShow isDeleteTag:(BOOL)isDeletetag{
    __block CGRect rect = [self.selectedRects.firstObject CGRectValue];
    [self.selectedRects enumerateObjectsUsingBlock:^(NSValue * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            return;
        }
        rect = CGRectUnion(rect, obj.CGRectValue);
    }];
    [self showMenueInRect:rect cidianShow:ciDianShow isDeleteTag:isDeletetag];
}

- (void)hideMenu {
    [self resignFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO];
}

- (void)zytrCopy:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(selectionViewMenuClicked:)]) {
        [_delegate selectionViewMenuClicked:ZYTRSelectionClick_copy];
    }
}

- (void)zytrFavor:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(selectionViewMenuClicked:)]) {
        [_delegate selectionViewMenuClicked:ZYTRSelectionClick_favor];
    }
}

- (void)zytrTag:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(selectionViewMenuClicked:)]) {
        [_delegate selectionViewMenuClicked:ZYTRSelectionClick_tag];
    }
}

- (void)zytrDeleteTag:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(selectionViewMenuClicked:)]) {
        [_delegate selectionViewMenuClicked:ZYTRSelectionClick_deletetag];
    }
}

- (void)zytrSearch:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(selectionViewMenuClicked:)]) {
        [_delegate selectionViewMenuClicked:ZYTRSelectionClick_search];
    }
}

- (void)zytrKonwledge:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(selectionViewMenuClicked:)]) {
        [_delegate selectionViewMenuClicked:ZYTRSelectionClick_konwledge];
    }
}

#pragma mark Helper

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIView *)maskViewsContainer {
    if (!_maskViewsContainer) {
        _maskViewsContainer = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_maskViewsContainer];
    }
    return _maskViewsContainer;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.maskViewsContainer.frame = self.bounds;
}

- (ZYTextGrabber *)startGrabber {
    if (!_startGrabber) {
        _startGrabber = [[ZYTextGrabber alloc] initWithPosition:PositionZero];
        _startGrabber.startGrabber = YES;
        _startGrabber.hidden = YES;
        CGRect dotRect = [_startGrabber convertRect:_startGrabber.dot.frame toView:self];
        self.startTouchDot = [[UIView alloc] initWithFrame:CGRectInset(dotRect, -10, -10)];
        self.startTouchDot.backgroundColor = [UIColor clearColor];//[UIColor redColor];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(startDotPan:)];
        [self.startTouchDot addGestureRecognizer:pan];
        [self addSubview:self.startTouchDot];
        [self addSubview:_startGrabber];
    }
    return _startGrabber;
}

- (ZYTextGrabber *)endGrabber {
    if (!_endGrabber) {
        _endGrabber = [[ZYTextGrabber alloc] initWithPosition:PositionZero];
        _endGrabber.startGrabber = NO;
        _endGrabber.hidden = YES;
        CGRect dotRect = [_endGrabber convertRect:_startGrabber.dot.frame toView:self];
        self.endTouchDot = [[UIView alloc] initWithFrame:CGRectInset(dotRect, -10, -10)];
        self.endTouchDot.backgroundColor = [UIColor clearColor];//[UIColor greenColor];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(endDotPan:)];
        [self.endTouchDot addGestureRecognizer:pan];
        [self addSubview:self.endTouchDot];
        
        [self addSubview:_endGrabber];
    }
    return _endGrabber;
}

@end
