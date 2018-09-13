//
//  ZYTRPageViewController.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRPageViewController.h"
#import "ZYTextReaderView.h"
#import "ZYTRFunctionView.h"
#import "ZYMangifiterView.h"
#import "ZYTRSelectionView.h"

#import "ZYTRManager.h"
#import "ZYChapterModel.h"
#import "ZYTRViewController.h"

@interface ZYTRPageViewController ()<ZYTRSelectionViewDelegate>

@property (nonatomic, strong) ZYTextReaderView *textView;

@property (nonatomic, strong) ZYMangifiterView *magnifierView;

@property (nonatomic, assign) NSRange seletedRange;

@property (nonatomic, strong) ZYTRSelectionView *selectionView;
/*拖动模式下起始位置*/
@property (nonatomic, assign) NSUInteger startLoaction;
/*拖动模式下结束位置*/
@property (nonatomic, assign) NSUInteger endLcation;

@property (nonatomic, strong) ZYTRFunctionView *funView;

@end

@implementation ZYTRPageViewController {
     UIGestureRecognizer *_tap;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.view addGestureRecognizer:({
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress;
    })];
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        _tap = tap;
        tap.enabled = NO;
        tap;
    })];
    
    [self textViewShow];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearSelected];
}

- (void)textViewShow {
    
    CGFloat topOff = [[self class] textTopOff];
    CGFloat bottomOff = [[self class] textBottomOff];;
    
    //__weak typeof(self) wself = self;
    ZYTextReaderView *textView = [[ZYTextReaderView alloc] initWithFrame:CGRectMake(15, topOff, self.view.bounds.size.width-30, self.view.bounds.size.height-topOff-bottomOff)];
    textView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [self.view addSubview:textView];
    self.textView = textView;

    ZYTRData *data = self.data;
    textView.data = data;
    [textView setHeight:data.height];
    
    self.selectionView = [[ZYTRSelectionView alloc] initWithFrame:self.textView.frame];
    _selectionView.delegate = self;
    [self.view addSubview:_selectionView];    
    
    ZYTRFunctionView *funcV = [[ZYTRFunctionView alloc] initWithFrame:self.view.bounds];
    self.funView = funcV;
    self.funView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.funView];
    if (data.tagRanges.count) {
        [self funViewReDrawTag];
    }
}

- (void)redrawReadView {
    self.textView.data = self.data;
    self.textView.height = self.data.height;
    [self.textView setNeedsDisplay];
    [self funViewReDrawTag];
}

#pragma mark TagRanges

- (void)updateTagRangesWithRange:(NSRange)cRange isDelete:(BOOL)isDelete{
    NSRange cotentRange = self.data.contentRange;
    //NSUInteger contentLength  = cotentRange.location + (cotentRange.length - 1);
    if (NSMaxRange(cRange) > NSMaxRange(cotentRange)) {
        return;
    }
    NSRange rangeInChapter = NSMakeRange(cotentRange.location + cRange.location, cRange.length);
    ZYTRManager *manager = [ZYTRManager currentManager];
    ZYChapterModel *chapterM = [manager updateChapterTagRangeWithChapterIndex:self.chapterIndex rangeInChapter:rangeInChapter isDelete:isDelete];
    self.data.tagRanges = [manager tagRangesInChapter:chapterM withSubRange:cotentRange];
    [self funViewReDrawTag];
    [self cancelSelected];
}

- (void)funViewReDrawTag {
    NSMutableArray *mRecArr = [NSMutableArray array];
    ZYTRData *data = self.data;
    if (data.tagRanges) {
        [data.tagRanges enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [(NSValue *)obj rangeValue];
            NSArray *rectsArr = [data.layout lineRectsAtRanges:range textHeight:data.height];
            [mRecArr addObjectsFromArray:rectsArr];
        }];
        self.funView.pointArr = [self.funView pointArrWithRectArr:mRecArr fromView:self.textView];
    }
    [self.funView setNeedsDisplay];
}


#pragma mark Actions

- (void)tap:(id)sender {
    [self clearSelected];
}

- (void)longPress:(id)sender {
    if (self.isCover) {
        return;
    }
    UILongPressGestureRecognizer *lp = (UILongPressGestureRecognizer *)sender;
    CGPoint originPoint = [lp locationInView:self.view];
    CGPoint point = [self.view convertPoint:originPoint toView:self.textView];
    if (lp.state == UIGestureRecognizerStateBegan || lp.state == UIGestureRecognizerStateChanged) {
        [self.selectionView hideMenu];
        [self.selectionView hideGrabber];
        [self showMangifiter];
        if (_magnifierView) _magnifierView.touchPoint = originPoint;
        
        ZYTextGlyphWrapper *glyph = [self.data.layout glyphAtPoint:point];
        if (glyph) {
            [self selectAtRange:NSMakeRange(glyph.index, 1) showGrabber:NO isTTs:NO];
        }
        //        else {
        //            self.seletedRange = NSRangeNull;
        //            _startLoaction = 0;
        //            _endLcation = 0;
        //        }
        //if (lp.state == UIGestureRecognizerStateBegan) {
        if (!NSEqualRanges(self.seletedRange, NSRangeNull) && !NSEqualRanges(self.seletedRange, NSRangeZero)) {
            //                ZYTextGlyphWrapper * g = [self.data.layout glyphAtLocation:self.seletedRange.location];
            //                CGRect r = CGRectOffset(CGRectFromPosition(g.startPosition, 10), -5, 0);
            //                r = CGRectInset(r, 0, -5);
            //                if (CGRectContainsPoint(r, point)) {
            //                    NSInteger stableLoc = NSMaxRange(self.seletedRange);
            //                    _startLoaction = stableLoc;
            //                    _endLcation = self.seletedRange.location + self.seletedRange.length;
            //                }else {
            //                    g = [self.data.layout glyphAtLocation:NSMaxRange(self.seletedRange) - 1];
            //                    r = CGRectOffset(CGRectFromPosition(g.endPosition, 10), -5, 0);
            //                    r = CGRectInset(r, 0, -5);
            //                    if (CGRectContainsPoint(r, point)) {
            _startLoaction = self.seletedRange.location;
            _endLcation = self.seletedRange.location + self.seletedRange.length;
            //                    }
            //                }
        }
        //}
    }else if (lp.state == UIGestureRecognizerStateEnded) {
        [self hideManfiter];
        BOOL cidianShow = YES;
        BOOL isDeleteTag = NO;
        if (!NSEqualRanges(self.seletedRange, NSRangeNull) && !NSEqualRanges(self.seletedRange, NSRangeZero)) {
            ZYTRManager *manager = [ZYTRManager currentManager];
            ZYChapterModel *chapterM = [manager chapterMWithChapterIndex:self.chapterIndex];
            NSRange rangeInChapter = NSMakeRange(self.seletedRange.location+self.data.contentRange.location, self.seletedRange.length);
            if ([manager currentTagRange:rangeInChapter containsInChapterM:chapterM]) {
                isDeleteTag = YES;
            }
            [self.selectionView showGrabber];
            [self.selectionView showMenue:cidianShow isDeleteTag:isDeleteTag];
        }
    }
}


#pragma mark Manfiter
- (void)showMangifiter {
    if (!_magnifierView) {
        self.magnifierView = [[ZYMangifiterView alloc] init];
        self.magnifierView.showView = self.view;
        [self.view addSubview:self.magnifierView];
    }
}

- (void)hideManfiter {
    if (_magnifierView) {
        [self.magnifierView removeFromSuperview];
        self.magnifierView = nil;
    }
}

#pragma mark About Select
-(void)cancelSelected {
    [_selectionView updateSelectedRects:nil startGrabberPosition:PositionZero endGrabberPosition:PositionZero grabberShow:NO isTTs:NO];
    self.seletedRange = NSRangeNull;
}

- (void)clearSelected {
    [self.selectionView hideMenu];
    [self cancelSelected];
    _tap.enabled = NO;
}

- (void)selectAtRange:(NSRange)range showGrabber:(BOOL)showGrabber isTTs:(BOOL)isTTs {
    if (NSEqualRanges(self.seletedRange, range)) {
        return;
    }
    ZYTextGlyphWrapper * gA = [self.data.layout glyphAtLocation:range.location];
    if (!gA) {
        return;
    }
    ZYTextGlyphWrapper * gB = [self.data.layout glyphAtLocation:NSMaxRange(range) - 1];
    if (!gB) {
        return;
    }
    if (gA.index > gB.index) {
        SwapoAB(gA, gB);
    }
    NSArray * rects = [self.data.layout selectedRectsBetweenLocationA:gA.index andLocationB:(gB.index + 1)];
    BOOL success = [self.selectionView updateSelectedRects:rects startGrabberPosition:gA.startPosition endGrabberPosition:gB.endPosition grabberShow:showGrabber isTTs:isTTs];
    if (success) {
        self.seletedRange = NSMakeRange(gA.index, gB.index - gA.index + 1);
        if (!isTTs) {
           _tap.enabled = YES;
        }
    }else {
        self.seletedRange = NSRangeNull;
        _tap.enabled = NO;
    }
}

#pragma mark SelectViewDelegate

- (void)selectionViewDotPanMove:(UIPanGestureRecognizer *)pan isStartGabber:(BOOL)isStartGabber {
    if ([self.selectionView grabberIsHidden]) {
        return;
    }
    CGPoint originPoint = [pan locationInView:self.selectionView];
    originPoint = [self.selectionView convertPoint:originPoint toView:self.view];
    CGPoint point = [self.view convertPoint:originPoint toView:self.textView];
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        [self.selectionView hideMenu];
        [self showMangifiter];
        if (_magnifierView) _magnifierView.touchPoint = originPoint;
        
        NSUInteger loc = [self.data.layout closestLocFromPoint:point];
        //NSLog(@"isS:%d sartL:%lu endL:%lu cL:%lu",isStartGabber,(unsigned long)_startLoaction,(unsigned long)_endLcation,(unsigned long)loc);
        if (loc == NSNotFound) {
            return;
        }
        if (isStartGabber) {
            if (loc >= _endLcation) {
                return;
            }
            _startLoaction = loc;
        }else {
            if (loc <= _startLoaction) {
                return;
            }
            _endLcation = loc;
        }
        //NSLog(@"-- is start--%d",isStartGabber);
        NSRange r = NSMakeRangeBetweenLocation(_startLoaction, _endLcation);
        //NSLog(@"-- start:%ld - end:%ld - r:%@ --",_startLoaction,_endLcation,[NSValue valueWithRange:r]);
        [self selectAtRange:r showGrabber:YES isTTs:NO];
    }else if (pan.state == UIGestureRecognizerStateEnded) {
        BOOL cidianShow = NO;
        BOOL isDeleteTag = NO;
        if (self.seletedRange.length <= 2) {
            cidianShow = YES;
        }
        ZYTRManager *manager = [ZYTRManager currentManager];
        ZYChapterModel *chapterM = [manager chapterMWithChapterIndex:self.chapterIndex];
        NSRange rangeInChapter = NSMakeRange(self.seletedRange.location+self.data.contentRange.location, self.seletedRange.length);
        if ([manager currentTagRange:rangeInChapter containsInChapterM:chapterM]) {
            isDeleteTag = YES;
        }
        [self hideManfiter];
        //[self.selectionView showGrabber];
        [self.selectionView showMenue:cidianShow isDeleteTag:isDeleteTag];
    }
}


- (void)selectionViewMenuClicked:(ZYTRSelectionClickType)clickType {
    NSString *selecStr = [self.data.content attributedSubstringFromRange:_seletedRange].string;
    //NSLog(@"--selected strings-%@",selecStr);
    if (clickType == ZYTRSelectionClick_tag) {
        NSRange cRange = _seletedRange;
        [self updateTagRangesWithRange:cRange isDelete:NO];
    }
    else if (clickType == ZYTRSelectionClick_deletetag) {
        NSRange cRange = _seletedRange;
        [self updateTagRangesWithRange:cRange isDelete:YES];
    }
    else if (clickType == ZYTRSelectionClick_copy) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:selecStr];
    }
    else if (clickType == ZYTRSelectionClick_search) {
        UIReferenceLibraryViewController *vc = [[UIReferenceLibraryViewController alloc] initWithTerm:selecStr];
        [self presentViewController:vc animated:YES completion:nil];
    }
}


#pragma mark TTS

- (void)readWithRange:(NSRange)range {
    [self selectAtRange:range showGrabber:NO isTTs:YES];
}

- (void)clearRead {
    [self cancelSelected];
}

#pragma mark Helper

- (NSDictionary *)imageInfoPoint:(CGPoint)point {
    NSDictionary *dic = [self.textView imageInfoAtPoint:[self.view convertPoint:point toView:self.textView]];
    if (dic) {
        CGRect rect = [(NSValue *)[dic valueForKey:@"imgRect"] CGRectValue];
        rect = [self.textView convertRect:rect toView:self.view];
        return @{@"imgName":[dic valueForKey:@"imgName"], @"imgRect":[NSValue valueWithCGRect:rect]};
    }else {
        return nil;
    }
}

+ (CGSize)textViewSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 2*[self textLeftOff], [UIScreen mainScreen].bounds.size.height - [self textTopOff] - [self textBottomOff]);
}

+ (CGFloat)textLeftOff {
    return 15;
}

+ (CGFloat)textTopOff {
    CGFloat topOff = 35;
    if (iPhoneX_zytr) {
        topOff = 50;
    }
    return topOff;
}

+ (CGFloat)textBottomOff {
    CGFloat bottomOff = 15;
    if (iPhoneX_zytr) {
        bottomOff = 40;
    }
    return bottomOff;
}

- (void)setData:(ZYTRData *)data {
    if (_data) {
        _data = nil;
    }
    _data = data;
}

- (void)dealloc {
    _data = nil;
    _textView = nil;
    _funView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
