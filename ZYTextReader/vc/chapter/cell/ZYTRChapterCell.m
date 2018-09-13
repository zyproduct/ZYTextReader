//
//  ZYTRChapterCell.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/27.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRChapterCell.h"
#import "Masonry.h"

@implementation ZYTRChapterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews {
    self.chapterLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.chapterLabel];
    self.chapterLabel.textColor = [UIColor blackColor];
    self.chapterLabel.font = [UIFont systemFontOfSize:16.0];
    [self.chapterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(15);
    }];
    
    self.sectionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.sectionLabel];
    self.sectionLabel.textColor = [UIColor grayColor];
    self.sectionLabel.font = [UIFont systemFontOfSize:14.0];
    [self.sectionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(30);
    }];
    
    //__weak typeof(self) wself = self;
    self.pageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.pageLabel];
    self.pageLabel.textColor = [UIColor grayColor];
    self.pageLabel.font = [UIFont systemFontOfSize:15.0];
    [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-10);
    }];
    
    UILabel *spLine = [[UILabel alloc] initWithFrame:CGRectZero];
    spLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.contentView addSubview:spLine];
    [spLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.height.mas_offset(0.8);
        make.bottom.mas_offset(0);
        make.right.mas_offset(0);
    }];
}

- (void)setCellType:(ZYTRChapterCellType)cellType {
    _cellType = cellType;
    if (cellType == ZYTRChapterCell_section) {
        self.chapterLabel.hidden = YES;
        self.sectionLabel.hidden = NO;
    }else {
        self.chapterLabel.hidden = NO;
        self.sectionLabel.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
