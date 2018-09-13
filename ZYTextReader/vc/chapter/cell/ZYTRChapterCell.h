//
//  ZYTRChapterCell.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/27.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZYTRChapterCell_chapter,
    ZYTRChapterCell_section,
} ZYTRChapterCellType;

@interface ZYTRChapterCell : UITableViewCell

@property (nonatomic, strong) UILabel *chapterLabel;

@property (nonatomic, strong) UILabel *sectionLabel;

@property (nonatomic, strong) UILabel *pageLabel;

@property (nonatomic, assign) ZYTRChapterCellType cellType;


@end
