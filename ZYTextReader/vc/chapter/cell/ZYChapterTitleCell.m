//
//  ZYChapterTitleCell.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/9/4.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYChapterTitleCell.h"
#import "Masonry.h"

@implementation ZYChapterTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews {
    CGFloat hSapce = 15.0f;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, hSapce, 0, -hSapce));
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
