//
//  ZYTRViewController.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRViewController.h"
#import "ZYTRPageViewController.h"
#import "ZYTRChapterVC.h"
#import "NYTPhotosViewController.h"
#import "NYTPhotoViewerArrayDataSource.h"
#import "NYTPhotoData.h"
//
#import "ZYTRParserConfig.h"
#import "ZYTRParser.h"
#import "ZYRederModel.h"
#import "ZYChapterModel.h"
#import "ZYTRManager.h"
#import "ZYTRDataBase.h"
#import "UIView+ZYFrame.h"
//
#import "ZYControlView.h"
#import "ZYTRTTSCoverView.h"


@interface ZYTRViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource, NYTPhotosViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPageViewController *scrollVC;

@property (nonatomic, strong) ZYControlView *controlView;

//当前章节
@property (nonatomic, assign) NSInteger chapterIndex;
//将要变化的章节
@property (nonatomic, assign) NSInteger chapterChange;

//当前页码
@property (nonatomic, assign) NSInteger pageIndex;
//将要变化的页码
@property (nonatomic, assign) NSInteger pageChange;

@property (nonatomic, assign) BOOL controlShow;

@property (nonatomic, strong) ZYTRTTSCoverView *ttsCoverView;

@end

@implementation ZYTRViewController {
    BOOL _isTramsition; //是否在翻动中
    UIImageView *_clickImgView;   //当前点击image View
    UITapGestureRecognizer *_tap;
    //
    //NSMutableDictionary *_currentTTSInfo;
}

static ZYTRViewController *currentTRVC = nil;

- (instancetype)init {
    if (self = [super init]) {
        currentTRVC = self;
    }
    return self;
}

+ (instancetype)currentInstance {
    return currentTRVC;
}

+ (void)clearInstance {
    currentTRVC = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    //tap.delegate = self;
    _tap = tap;
    [self.view addGestureRecognizer:tap];
    //
    [self loadManager];
}

- (void)createUIs {
    self.scrollVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _scrollVC.view.frame = self.view.bounds;
    _scrollVC.delegate = self;
    _scrollVC.dataSource = self;
    [self addChildViewController:self.scrollVC];
    [self.view addSubview:self.scrollVC.view];
    //禁止左右边缘点击翻页
    for (UIGestureRecognizer *ges in _scrollVC.gestureRecognizers) {
        if ([ges isKindOfClass:[UITapGestureRecognizer class]]) {
            ges.enabled = NO;
        }
    }
    [self.scrollVC didMoveToParentViewController:self];
    
    ZYTRPageViewController *pageVC = [self pageVCWithChapterIndex:_chapterIndex pageIndex:_pageIndex];
    [self.scrollVC setViewControllers:@[pageVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    //
    __weak typeof(self) wslef = self;
    BOOL playShow = YES;
//    //test
//    if ([self.keyId isEqualToString:@"60002_1198"]) {
//        playShow = YES;
//    }
    ZYTRManager *manager = [ZYTRManager currentManager];
    self.controlView = [[ZYControlView alloc] initWithFrame:self.view.bounds title:manager.readerM.name toolBarClick:^(ZYTRToolBarType type) {
        if (type == ZYTRToolBarType_back) {
            [wslef dismissReader];
        }else if (type == ZYTRToolBarType_menu) {
            [wslef showChapterVC];
        }else if (type == ZYTRToolBarType_minusFont) {
            manager.config.fontChange -= 2;
            [wslef recreateReaderData];
        }else if (type == ZYTRToolBarType_extendFont) {
            manager.config.fontChange += 2;
            [wslef recreateReaderData];
        }
    } playShow:playShow];
    self.controlView.hidden = YES;
    [self.view addSubview:self.controlView];
}

- (void)loadManager{
    [[ZYTRDataBase sharedDataBase] getManagerDataWithKeyId:self.keyId finish:^(ZYTRManager *manager) {
        if (!manager) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initialReaderData];
            });
        }else {
            CGSize textSize = [ZYTRPageViewController textViewSize];
            manager.config.width = textSize.width;
            manager.config.height = textSize.height;
            self->_chapterIndex = manager.cIndex;
            self->_pageIndex = manager.pIndex;
            [manager cacheInitial];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createUIs];
            });
        }
    }];
}

- (void)updateManagerCache {
    [[ZYTRDataBase sharedDataBase] updateManager:[ZYTRManager currentManager] withKeyId:self.keyId];
}

- (void)initialReaderData {
    //config
    ZYTRParserConfig *config = [[ZYTRParserConfig alloc] init];
    CGSize textSize = [ZYTRPageViewController textViewSize];
    config.width = textSize.width;
    config.height = textSize.height;

    _chapterIndex = 0;
    _pageIndex = 0;
    UIActivityIndicatorView *ac = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:ac];
    ac.center = self.view.center;
    [ac startAnimating];
    [ZYTRManager managerWithDataDic:self.dataDic config:config name:self.name finish:^(ZYTRManager *manager) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createUIs];
            [ac stopAnimating];
            [ac removeFromSuperview];
        });
        [[ZYTRDataBase sharedDataBase] insertManagerData:manager withKeyId:self.keyId];
    }];
}

- (void)recreateReaderData {
    
    ZYTRManager *manager = [ZYTRManager currentManager];
    ZYChapterModel *chapterM = [manager chapterMWithChapterIndex:_chapterIndex];

    if (_pageIndex > (chapterM.pageArr.count - 1)) {
        _pageIndex = (chapterM.pageArr.count - 1);
    }
    NSInteger location = [chapterM.pageArr[_pageIndex] integerValue];
    NSInteger length = 0;
    if (_pageIndex == (chapterM.pageArr.count - 1)) {
        length = chapterM.content.length - location;
    }else {
        length = [chapterM.pageArr[_pageIndex+1] integerValue] - location;
    }
    BOOL isParaHead = NO;
    NSAttributedString *content = [chapterM.content attributedSubstringFromRange:NSMakeRange(location, length)];
    if (location > 0) {
        NSAttributedString *preContent = [chapterM.content attributedSubstringFromRange:NSMakeRange(location-1, 1)];
        if (![preContent.string isEqualToString:@"\n"]) {
            isParaHead = YES;
        }
    }
    ZYTRPageViewController *pageVC = self.scrollVC.viewControllers.firstObject;
    if (content.length) {
        ZYTRData *data = [ZYTRParser dataWithContent:content config:manager.config isParaHead:isParaHead];
        if ([chapterM.type isEqualToString:@"cover"]) {
            data.height = [ZYTRPageViewController textViewSize].height;
        }
        [data createLayout];
        NSRange contentRange = NSMakeRange(location, length);
        data.contentRange = contentRange;
        data.tagRanges = [manager tagRangesInChapter:chapterM withSubRange:contentRange];
        pageVC.data = data;
    }
    pageVC.chapterIndex = _chapterIndex;
    pageVC.pageIndex = _pageIndex;
    [pageVC redrawReadView];
    
    [manager recreateReaderMAsync:^{
        [self updateManagerCache];
    }];
}

- (void)showControllViews {
    __weak typeof(self) wself = self;
    [self.controlView showControllViewsComplete:^{
        wself.controlShow = YES;
    }];
}

- (void)hideControllViews {
    __weak typeof(self) wself = self;
    [self.controlView hideControllViewsComplete:^{
        wself.controlShow = NO;
    }];
}

- (ZYTRPageViewController *)pageVCWithChapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex {
    
    ZYTRManager *manager = [ZYTRManager currentManager];
    ZYChapterModel *chapterM = [manager chapterMWithChapterIndex:chapterIndex];
    NSInteger location = [chapterM.pageArr[pageIndex] integerValue];
    NSInteger length = 0;
    if (pageIndex == (chapterM.pageArr.count - 1)) {
        length = chapterM.content.length - location;
    }else {
        length = [chapterM.pageArr[pageIndex+1] integerValue] - location;
    }
    BOOL isParaHead = NO;
    NSAttributedString *content = [chapterM.content attributedSubstringFromRange:NSMakeRange(location, length)];
    if (location > 0) {
        NSAttributedString *preContent = [chapterM.content attributedSubstringFromRange:NSMakeRange(location-1, 1)];
        if (![preContent.string isEqualToString:@"\n"]) {
            isParaHead = YES;
        }
    }
    ZYTRPageViewController *pageVC = [[ZYTRPageViewController alloc] init];
    if (content.length) {
        ZYTRData *data = [ZYTRParser dataWithContent:content config:manager.config isParaHead:isParaHead];
        if ([chapterM.type isEqualToString:@"cover"]) {
            data.height = [ZYTRPageViewController textViewSize].height;
        }
        [data createLayout];
        NSRange contentRange = NSMakeRange(location, length);
        data.contentRange = contentRange;
        data.tagRanges = [manager tagRangesInChapter:chapterM withSubRange:contentRange];
        pageVC.data = data;
    }
    pageVC.isCover = [chapterM.type isEqualToString:@"cover"];
    pageVC.chapterIndex = chapterIndex;
    pageVC.pageIndex = pageIndex;
    return pageVC;
}

- (BOOL)gotoPageViewControllerWithChapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex isTTSGo:(BOOL)isTTSGo {
    
    ZYTRManager *manager = [ZYTRManager currentManager];
    ZYChapterModel  *chapterM = [manager chapterMWithChapterIndex:chapterIndex];
    if (pageIndex < 0 || chapterIndex < 0) {
        return NO;
    }
    else if (pageIndex > (chapterM.pageArr.count-1) || chapterIndex > (manager.readerM.chapters.count-1)) {
        return NO;
    }
    
    ZYTRPageViewController *pageVC = [self pageVCWithChapterIndex:chapterIndex pageIndex:pageIndex];
    
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (chapterIndex == _chapterIndex) {
        if (chapterIndex < _chapterIndex) {
            direction = UIPageViewControllerNavigationDirectionReverse;
        }
    }else {
        if (pageIndex < _pageIndex) {
            direction = UIPageViewControllerNavigationDirectionReverse;
        }
    }
    
    _chapterIndex = chapterIndex;
    _pageIndex = pageIndex;
    NSString *keyId = self.keyId;
   
    
    [self.scrollVC setViewControllers:@[pageVC] direction:direction animated:NO completion:^(BOOL finished) {
        //
        [[ZYTRDataBase sharedDataBase] updateChapterIndex:chapterIndex pageIndex:pageIndex withKeyId:keyId];
    }];
    return YES;
}

- (BOOL)goToNextPage:(BOOL)isTTS {
    NSInteger newPage = _pageIndex + 1;
    NSInteger newChapter = _chapterIndex;
    ZYTRManager *manager = [ZYTRManager currentManager];
    ZYChapterModel  *chapterM = [manager chapterMWithChapterIndex:_chapterIndex];
    if (newPage > chapterM.pageArr.count - 1) {
        newChapter += 1;
        newPage = 0;
    }
    return [self gotoPageViewControllerWithChapterIndex:newChapter pageIndex:newPage isTTSGo:isTTS];
}

#pragma mark PageViewController Delegate && Datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
   // NSLog(@"===before===");
    if (_isTramsition) {
        return nil;
    }
    _pageChange = _pageIndex;
    _chapterChange = _chapterIndex;
    if (_chapterChange == 0 && _pageChange == 0) {
        return nil;
    }
    ZYTRManager *manager = [ZYTRManager currentManager];
    if (_pageChange == 0) {
        _chapterChange--;
        ZYChapterModel  *chapterM = [manager chapterMWithChapterIndex:_chapterChange];
        _pageChange = (chapterM.pageArr.count - 1);
    }else {
        _pageChange--;
    }
    //NSLog(@"----beforeVC----chapter:%d page:%d",_chapterChange,_pageChange);
    return [self pageVCWithChapterIndex:_chapterChange pageIndex:_pageChange];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    //NSLog(@"===after===");
    if (_isTramsition) {
        return nil;
    }
    _pageChange = _pageIndex;
    _chapterChange = _chapterIndex;
    ZYTRManager *manager = [ZYTRManager currentManager];
    ZYChapterModel  *chapterM = [manager chapterMWithChapterIndex:_chapterChange];
    if (_pageChange == (chapterM.pageArr.count-1) && _chapterChange == (manager.readerM.chapters.count-1)) {
        return nil;
    }
    
    if (_pageChange == (chapterM.pageArr.count-1)) {
        _chapterChange++;
        _pageChange = 0;
    }else {
        _pageChange++;
    }
    //NSLog(@"----afterVC----chapter:%d page:%d",_chapterChange,_pageChange);
    return [self pageVCWithChapterIndex:_chapterChange pageIndex:_pageChange];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    _isTramsition = YES;
    _chapterIndex = _chapterChange;
    _pageIndex = _pageChange;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    _isTramsition = NO;
    if (!completed) {
         ZYTRPageViewController *prePageVC = (ZYTRPageViewController *)previousViewControllers.firstObject;
        _chapterIndex= prePageVC.chapterIndex;
        _pageIndex = prePageVC.pageIndex;
    }else {
         ZYTRPageViewController *cpageVC = (ZYTRPageViewController *)pageViewController.viewControllers.firstObject;
        _chapterIndex = cpageVC.chapterIndex;
        _pageIndex = cpageVC.pageIndex;
    }
    [[ZYTRDataBase sharedDataBase] updateChapterIndex:_chapterIndex pageIndex:_pageIndex withKeyId:self.keyId];
}

#pragma mark Actions
- (void)tap:(id)sender {
    if (_isTramsition) {
        return;
    }
    if (_controlShow) {
        [self hideControllViews];
    }else {
        ZYTRManager *manager = [ZYTRManager currentManager];
        ZYChapterModel  *chapterM = [manager chapterMWithChapterIndex:_chapterIndex];
        BOOL isCover = [chapterM.type isEqualToString:@"cover"];
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
        CGPoint point = [tap locationInView:self.view];
        ZYTRPageViewController *pageVC = self.scrollVC.viewControllers.firstObject;
        NSDictionary *imgInfo = [pageVC imageInfoPoint:point];
        if (!isCover && imgInfo) {
            [self showImageViewerWithImageInfo:imgInfo];
        }else {
            [self showControllViews];
        }
    }
}

- (void)dismissReader {
    [self dismissViewControllerAnimated:YES completion:nil];
    [ZYTRManager cleanManager];
    [[ZYTRDataBase sharedDataBase] closeAndClean];
    [ZYTRViewController clearInstance];
}

- (void)showChapterVC {
    ZYTRManager *manager = [ZYTRManager currentManager];
    _tap.enabled = NO;
    [ZYTRChapterVC showChapterVCWithReaderM:manager.readerM parentVC:self clickChapter:^(NSUInteger chapterIndex, NSUInteger pageIndex) {
        [self gotoPageViewControllerWithChapterIndex:chapterIndex pageIndex:pageIndex isTTSGo:NO];
    } dismiss:^(BOOL isChoose){
        if (isChoose) {
            [self hideControllViews];
        }
        self->_tap.enabled = YES;
    }];
}

#pragma mark ImageViewer

- (void)showImageViewerWithImageInfo:(NSDictionary *)imgInfo {
    CGRect rect = [(NSValue *)[imgInfo valueForKey:@"imgRect"] CGRectValue];
    NSString *imgName = [imgInfo valueForKey:@"imgName"];
    _clickImgView = [[UIImageView alloc] initWithFrame:rect];
    _clickImgView.image = [UIImage imageNamed:imgName];
    [self.view addSubview:_clickImgView];
    
    
    NYTPhotoData *photo = [NYTPhotoData new];
    photo.image = [UIImage imageNamed:imgName];
    NYTPhotoViewerArrayDataSource *dataSource = [NYTPhotoViewerArrayDataSource dataSourceWithPhotos:@[photo]];
    
    NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithDataSource:dataSource initialPhoto:nil delegate:self];
    [self presentViewController:photosViewController animated:YES completion:nil];
//    [ZYImageViewer showImageViewerWithVC:self imagesArr:@[[UIImage imageNamed:imgName]] delegate:self dismissComplete:^{
//        if (self->_clickImgView) {
//            [self->_clickImgView removeFromSuperview];
//            self->_clickImgView = nil;
//        }
//    }];
//    NSLog(@"--image:%@,frame:%@",imgName,NSStringFromCGRect(rect));
}

#pragma mark - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController referenceViewForPhoto:(id <NYTPhoto>)photo {
    return _clickImgView;
}


- (CGFloat)photosViewController:(NYTPhotosViewController *)photosViewController maximumZoomScaleForPhoto:(id <NYTPhoto>)photo {

    return 1.0f;
}

//- (NSString *)photosViewController:(NYTPhotosViewController *)photosViewController titleForPhoto:(id<NYTPhoto>)photo atIndex:(NSInteger)photoIndex totalPhotoCount:(nullable NSNumber *)totalPhotoCount {
//
//    
//    return nil;
//}

//- (void)photosViewController:(NYTPhotosViewController *)photosViewController didNavigateToPhoto:(id <NYTPhoto>)photo atIndex:(NSUInteger)photoIndex {
//    NSLog(@"Did Navigate To Photo: %@ identifier: %lu", photo, (unsigned long)photoIndex);
//}
//
//- (void)photosViewController:(NYTPhotosViewController *)photosViewController actionCompletedWithActivityType:(NSString *)activityType {
//    NSLog(@"Action Completed With Activity Type: %@", activityType);
//}
//
- (void)photosViewControllerDidDismiss:(NYTPhotosViewController *)photosViewController {
    if (_clickImgView) {
        [_clickImgView removeFromSuperview];
        _clickImgView = nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
