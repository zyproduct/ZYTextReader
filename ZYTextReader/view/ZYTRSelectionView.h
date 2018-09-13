//
//  ZYTRSelectionView.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/19.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYTRCommon.h"

@protocol ZYTRSelectionViewDelegate <NSObject>
@optional
//选中移动
- (void)selectionViewDotPanMove:(UIPanGestureRecognizer *)pan isStartGabber:(BOOL)isStartGabber;
//menu点击
- (void)selectionViewMenuClicked:(ZYTRSelectionClickType)clickType;
@end

@interface ZYTRSelectionView : UIView

@property (nonatomic, weak) id<ZYTRSelectionViewDelegate> delegate;

- (BOOL)updateSelectedRects:(NSArray *)rects startGrabberPosition:(ZYTRPosition)startP endGrabberPosition:(ZYTRPosition)endP grabberShow:(BOOL)grabberShow isTTs:(BOOL)isTTs;

//显示拖动点
- (void)showGrabber;

//隐藏拖动点
- (void)hideGrabber;

- (BOOL)grabberIsHidden;

//显示选项
- (void)showMenueInRect:(CGRect)rect cidianShow:(BOOL)cidianShow isDeleteTag:(BOOL)isDeletetag;

- (void)showMenue:(BOOL)cidianShow isDeleteTag:(BOOL)isDeletetag;

//隐藏选项
- (void)hideMenu;

@end
