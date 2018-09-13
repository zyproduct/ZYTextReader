//
//  ZYTRChapterVC.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/26.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRChapterVC.h"
#import "ZYRederModel.h"
#import "ZYChapterModel.h"
#import "ZYSectionModel.h"
#import "Masonry.h"
#import "UIView+ZYFrame.h"
#import "ZYTRCommon.h"
//
#import "ZYTRChapterCell.h"
#import "ZYChapterTagCell.h"
#import "ZYChapterTitleCell.h"

typedef enum : NSInteger {
    ZYChapterVCDisplayType_chapter,
    ZYChapterVCDisplayType_tags,
}ZYChapterVCDisplayType;

@interface ZYTRChapterVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZYRederModel *readerM;
@property (nonatomic, assign) ZYChapterVCDisplayType displayType;
@property (nonatomic, strong) NSArray *tagChaptersArr;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *tbView;

@property (nonatomic, strong) UIButton *chapterBtn;
@property (nonatomic, strong) UIButton *tagsBtn;

@property (nonatomic, copy) void(^clickBlock)(NSUInteger chapterIndex, NSUInteger pageIndex);
@property (nonatomic, copy) void(^dismissBlock)(BOOL isChoose);
@end

@implementation ZYTRChapterVC {
    BOOL _animating;
    CGFloat _contentW;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _contentW = 280;
    [self initialDatas];
    self.view.backgroundColor = [UIColor clearColor];
    self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    self.bgView.alpha = 0;
    [self.view addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBg:)];
    [self.bgView addGestureRecognizer:tap];
    [self createSubViews];
}

- (void)initialDatas {
    
    ZYRederModel *readerM = [self.readerM copy];
    
    CGFloat tagLabelW = _contentW - [ZYChapterTagCell tagExtraWidth];
    CGFloat tagLabelFont = [ZYChapterTagCell tagFont];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *tagChapArr = [NSMutableArray array];
        CGSize oneLineSize = [@"字" boundingRectWithSize:CGSizeMake(tagLabelW, 3000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:tagLabelFont]} context:nil].size;
        
        for (ZYChapterModel *chapM in readerM.chapters) {
            NSUInteger chapStartPage = chapM.startPage;
            NSArray *sectionArr = chapM.sectionsArr;
            NSArray *tagArr = chapM.tagRanges;
            tagArr = [tagArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSRange r1 = [(NSValue *)obj1 rangeValue];
                NSRange r2 = [(NSValue *)obj2 rangeValue];
                if (r1.location > r2.location) {
                    return NSOrderedDescending;
                }else {
                    return NSOrderedAscending;
                }
            }];
            
            NSMutableDictionary *tagDic = nil;  //记录tag信息
            NSMutableArray *itemTagArr = nil;
            if (tagArr.count) {
                tagDic = [NSMutableDictionary dictionary];
                [tagDic setValue:chapM.name forKey:@"name"];
                itemTagArr = [NSMutableArray array];
            }
            
            NSUInteger sectionIndex = 0;//section索引
            NSUInteger tagIndex = 0; //tag索引
            for (NSUInteger i = 0; i < chapM.pageArr.count; i++) {
                @autoreleasepool {
                NSNumber *pageN = chapM.pageArr[i];
                NSUInteger pageStartLocation = pageN.unsignedIntegerValue;//每页起始位置
                
                //处理section的所在页码
                if (sectionIndex < sectionArr.count) {
                    ZYSectionModel *sectionM = sectionArr[sectionIndex];
                    if (sectionM.sectionStartLocation < pageStartLocation) {
                        NSUInteger secPage = i > 0 ? i-1:i;
                        sectionM.sectionStartPage = secPage + chapStartPage;
                        sectionIndex++;
                    }else if(sectionM.sectionStartLocation >= pageStartLocation && i == chapM.pageArr.count-1) {
                        sectionM.sectionStartPage = i + chapStartPage;
                        sectionIndex++;
                    }
                }
                
                //处理tags所在页码
                if (tagArr.count || tagIndex < tagArr.count) {
                    
                    BOOL tagStop = NO;
                    while (!tagStop) {
                        if (tagIndex > tagArr.count - 1) {
                            tagStop = YES;
                            break;
                        }
                        NSUInteger tagPageIndex = i;
                        NSValue *rv = tagArr[tagIndex];
                        NSRange tagRange = [rv rangeValue];
                        BOOL valid = NO;
                        if (tagRange.location < pageStartLocation) {
                            tagPageIndex = i>0?i-1:i;
                            valid = YES;
                        }else {
                            if (i == chapM.pageArr.count-1) {
                                tagPageIndex =  i ;
                                valid = YES;
                            }else {
                                tagStop = YES;
                                break;
                            }
                        }
                        if (valid) {
                            NSUInteger chapterIndex = [readerM.chapters indexOfObject:chapM];
                            [tagDic setObject:@(chapterIndex) forKey:@"chapterIndex"];
                            NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
                            
                            NSString *content = [chapM.content attributedSubstringFromRange:tagRange].string;
                            [itemDic setValue:rv forKey:@"range"];
                            [itemDic setValue:content forKey:@"content"];
                            CGSize contentSize = [content boundingRectWithSize:CGSizeMake(tagLabelW, 3000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:tagLabelFont]} context:nil].size;
                            [itemDic setValue:[NSValue valueWithCGSize:contentSize] forKey:@"contentSize"];
                            NSInteger line = contentSize.height/oneLineSize.height;
                            [itemDic setValue:@(line) forKey:@"line"];
                            [itemDic setValue:@(tagPageIndex) forKey:@"pageIndex"];
                            [itemTagArr addObject:itemDic];
                            tagIndex++;
                        }

                    }
                }
            }
            }
            
            if (tagDic) {
                [tagDic setValue:itemTagArr forKey:@"tagArr"];
                [tagChapArr addObject:tagDic];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tagChaptersArr = tagChapArr;
            self.readerM = readerM;
            [self.tbView reloadData];
        });
    });
}

- (void)dealloc {
    self.clickBlock = nil;
    self.dismissBlock = nil;
    self.readerM = nil;
}

- (void)createSubViews {
    
    CGFloat headerH = 120;
    CGFloat bottomH = 80;
    CGFloat bottomoff = 0;
    if (iPhoneX_zytr) {
        headerH += 20.0;
        bottomoff = 20.0;
        bottomH += bottomoff;
    }
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(-_contentW, 0, _contentW, self.view.bounds.size.height)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contentView];
    
    UIView *headV = [self createHeaderViewWithHeight:headerH];
    UIView *bottomV = [self createBottomViewWithHeight:bottomH bottomOff:bottomoff];
    self.displayType = ZYChapterVCDisplayType_chapter;

    self.tbView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tbView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tbView.showsVerticalScrollIndicator = NO;
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
    self.tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:self.tbView];
    [self.tbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(headV.mas_bottom);
        make.bottom.equalTo(bottomV.mas_top);
    }];
    
    [self.tbView registerClass:[ZYTRChapterCell class] forCellReuseIdentifier:@"chapterCell"];
    [self.tbView registerClass:[ZYChapterTagCell class] forCellReuseIdentifier:@"tagCell"];
    [self.tbView registerClass:[ZYChapterTitleCell class] forCellReuseIdentifier:@"titleCell"];
    [self showContent];
}

- (UIView *)createHeaderViewWithHeight:(CGFloat)height {
    UIView *headV = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:headV];
    [headV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(height);
    }];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [headV addSubview:titleLabel];
    titleLabel.font = [UIFont boldSystemFontOfSize:19];
    titleLabel.text = self.readerM.name;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-15);
        make.centerX.mas_equalTo(0);
    }];
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
    [headV addSubview:bottomLine];
    bottomLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-1);
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.height.mas_equalTo(1);
    }];
    return headV;
}

- (UIView *)createBottomViewWithHeight:(CGFloat)height bottomOff:(CGFloat)bottomOff {
    UIView *bottomV = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:bottomV];
    [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(height);
    }];
    bottomV.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    bottomV.layer.shadowOffset = CGSizeMake(0, -0.5);
    bottomV.layer.shadowOpacity = 0.3;
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectZero];
    [bottomV addSubview:topLine];
    topLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    self.chapterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomV addSubview:self.chapterBtn];
    [self.chapterBtn setTitle:ZYTextLocal(@"menu") forState:UIControlStateNormal];
    [self.chapterBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.chapterBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [self.chapterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-bottomOff);
        make.width.equalTo(bottomV).multipliedBy(0.5);
    }];
    [self.chapterBtn addTarget:self action:@selector(chapterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tagsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomV addSubview:self.tagsBtn];
    [self.tagsBtn setTitle:ZYTextLocal(@"tag") forState:UIControlStateNormal];
    [self.tagsBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.tagsBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [self.tagsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-bottomOff);
        make.width.equalTo(bottomV).multipliedBy(0.5);
    }];
    [self.tagsBtn addTarget:self action:@selector(tagClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return bottomV;
}

- (void)showContent {
    if (_animating) {
        return;
    }
    _animating = YES;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bgView.alpha = 1;
        self.contentView.x = 0;
    } completion:^(BOOL finished) {
        self->_animating = NO;
    }];
}

- (void)dismissSelf:(BOOL)isChoose {
    if (_animating) {
        return;
    }
    _animating = YES;
    CGFloat contentW = self.contentView.width;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bgView.alpha = 0;
        self.contentView.x = -contentW;
    } completion:^(BOOL finished) {
        self->_animating = NO;
        self.readerM = nil;
        if (self.dismissBlock){
           self.dismissBlock(isChoose);
        }
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)setDisplayType:(ZYChapterVCDisplayType)displayType {
    _displayType = displayType;
    if (displayType == ZYChapterVCDisplayType_chapter) {
        [self.chapterBtn setTitleColor:RGB(72, 173, 250) forState:UIControlStateNormal];
        [self.tagsBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else if (displayType == ZYChapterVCDisplayType_tags) {
        [self.tagsBtn setTitleColor:RGB(72, 173, 250) forState:UIControlStateNormal];
        [self.chapterBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

#pragma mark TableView Delegate && Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.displayType == ZYChapterVCDisplayType_tags) {
        return self.tagChaptersArr.count;
    }else {
        return self.readerM.chapters.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.displayType == ZYChapterVCDisplayType_tags) {
        NSDictionary *tagDic = self.tagChaptersArr[section];
        NSArray *arr = [tagDic valueForKey:@"tagArr"];
        return (1+arr.count);
    }else {
        ZYChapterModel *chapterM = self.readerM.chapters[section];
        return (1+chapterM.sectionsArr.count);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.displayType == ZYChapterVCDisplayType_tags) {
        NSDictionary *tagDic = self.tagChaptersArr[indexPath.section];
        NSArray *arr = [tagDic valueForKey:@"tagArr"];
        if (indexPath.row == 0) {
            ZYChapterTitleCell *titleCell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
            titleCell.titleLabel.text = [tagDic valueForKey:@"name"];
            return titleCell;
        }else {
            NSDictionary *itemTag = arr[indexPath.row-1];
            ZYChapterTagCell *tagCell = [tableView dequeueReusableCellWithIdentifier:@"tagCell"];
            NSString *content = [itemTag valueForKey:@"content"];
            NSInteger lines = [[itemTag valueForKey:@"line"] integerValue];
            if (lines > 3) {
                lines = 3;
            }else if(lines <= 0) {
                lines = 1;
            }
            BOOL splineShow = NO;
            if (indexPath.row != arr.count) {
                splineShow = YES;
            }
            [tagCell dispalyContent:content lines:lines spLineShow:splineShow];
            return tagCell;
        }
        
    }else {
        ZYTRChapterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chapterCell"];
        ZYChapterModel *chapterM = self.readerM.chapters[indexPath.section];
        NSInteger startPage = chapterM.startPage;
        cell.chapterLabel.text = @"";
        cell.sectionLabel.text = @"";
        if (indexPath.row > 0 && chapterM.sectionsArr.count) {
            ZYSectionModel *sectionM = chapterM.sectionsArr[indexPath.row-1];
            cell.cellType = ZYTRChapterCell_section;
            cell.sectionLabel.text = sectionM.name;
            startPage = sectionM.sectionStartPage;
        }else {
            cell.chapterLabel.text = chapterM.name;
            cell.cellType = ZYTRChapterCell_chapter;
        }
       // cell.pageLabel.text = [NSString stringWithFormat:@"%ld",(long)startPage];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.displayType == ZYChapterVCDisplayType_tags) {
        if (indexPath.row == 0) {
            return 44.0f;
        }else {
            CGFloat minH = 40.0;
            CGFloat maxH = 80.0;
            CGFloat finalH = minH;
            NSDictionary *tagDic = self.tagChaptersArr[indexPath.section];
            NSArray *arr = [tagDic valueForKey:@"tagArr"];
            NSDictionary *itemTag = arr[indexPath.row-1];
            CGSize size = [(NSValue *)[itemTag valueForKey:@"contentSize"] CGSizeValue];
            CGFloat contentH = [ZYChapterTagCell topSpace] + [ZYChapterTagCell bottomSapce] + size.height;
            if (contentH > minH) {
                finalH = contentH > maxH ? maxH:contentH;
            }
            return finalH;
        }
    }else {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.clickBlock) {
        if (self.displayType == ZYChapterVCDisplayType_tags) {
            if (indexPath.row > 0) {
                NSDictionary *tagDic = self.tagChaptersArr[indexPath.section];
                NSArray *arr = [tagDic valueForKey:@"tagArr"];
                NSDictionary *itemTag = arr[indexPath.row-1];
                NSUInteger chapterIndex = [[tagDic valueForKey:@"chapterIndex"] unsignedIntegerValue];
                NSUInteger pageIndex = [[itemTag valueForKey:@"pageIndex"] unsignedIntegerValue];
                self.clickBlock(chapterIndex,pageIndex);
                [self dismissSelf:YES];
            }
        }else {
            ZYChapterModel *chapterM = self.readerM.chapters[indexPath.section];
            NSUInteger pageIndex = 0;
            if (indexPath.row > 0 && chapterM.sectionsArr.count) {
                ZYSectionModel *sectionM = chapterM.sectionsArr[indexPath.row-1];
                pageIndex = sectionM.sectionStartPage - chapterM.startPage;
            }
            self.clickBlock(indexPath.section,pageIndex);
            [self dismissSelf:YES];
        }
    }
}

#pragma mark Actions
- (void)tapBg:(id)sender {
    [self dismissSelf:NO];
}

- (void)chapterClicked:(id)sender {
    if (self.displayType == ZYChapterVCDisplayType_chapter) {
        return;
    }
    self.displayType = ZYChapterVCDisplayType_chapter;
    [self.tbView reloadData];
}

- (void)tagClicked:(id)sender {
    if (self.displayType == ZYChapterVCDisplayType_tags) {
        return;
    }
    self.displayType = ZYChapterVCDisplayType_tags;
    [self.tbView reloadData];
}

#pragma mark Public
+ (void)showChapterVCWithReaderM:(ZYRederModel *)readerM parentVC:(UIViewController *)parentVC clickChapter:(void(^)(NSUInteger chapterIndex, NSUInteger pageIndex))clickBlock dismiss:(void(^)(BOOL isChoose))dismissBlock {
    if (!readerM.chapters.count || !parentVC) {
        return;
    }
    ZYTRChapterVC *vc = [[ZYTRChapterVC alloc] init];
    vc.readerM = readerM;
    vc.clickBlock = clickBlock;
    vc.dismissBlock = dismissBlock;
    [parentVC addChildViewController:vc];
    [parentVC.view addSubview:vc.view];
    [vc didMoveToParentViewController:parentVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
