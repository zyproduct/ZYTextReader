//
//  ZYChapterTagCell.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/9/4.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYChapterTagCell.h"
#import "Masonry.h"
#import "ZYTRCommon.h"


@interface ZYChapterTagCell ()

@property (nonatomic, strong) UILabel *dotLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UILabel *spLine;

@end

@implementation ZYChapterTagCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews {
    CGFloat leftS = [ZYChapterTagCell leftSpace];
    CGFloat rightS = [ZYChapterTagCell rightSpace];
    CGFloat topS = [ZYChapterTagCell topSpace];
    CGFloat bottomS = [ZYChapterTagCell bottomSapce];
    CGFloat contentL = [ZYChapterTagCell contentLeft];
    CGFloat dotL = [ZYChapterTagCell dotL];
    
    UIView *dBgV = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:dBgV];
    dBgV.layer.cornerRadius = dotL/2.0;
    dBgV.layer.masksToBounds = YES;
    dBgV.backgroundColor = [RGB(238, 243, 249) colorWithAlphaComponent:1];
    [dBgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(dotL, dotL));
        make.left.mas_equalTo(leftS);
        make.top.mas_equalTo(topS);
    }];
    
    self.dotLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.dotLabel];
    self.dotLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *mAttrstr = [[NSMutableAttributedString alloc] initWithString:@"A"];
    NSDictionary *attriDic = @{(id)kCTFontAttributeName:[UIFont systemFontOfSize:12.0],
                               NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
                               };
    [mAttrstr addAttributes:attriDic range:NSMakeRange(0, 1)];
    self.dotLabel.attributedText = mAttrstr;
    [dBgV addSubview:self.dotLabel];
    [self.dotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-1);
    }];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.contentLabel];
    self.contentLabel.font = [UIFont systemFontOfSize:[ZYChapterTagCell tagFont]];
    self.contentLabel.textColor = [UIColor lightGrayColor];
    self.contentLabel.numberOfLines = 0;
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(dBgV.mas_right).offset(contentL);
        make.top.mas_equalTo(topS);
        make.bottom.mas_lessThanOrEqualTo(-bottomS);
        make.right.mas_equalTo(-rightS);
    }];
    
    self.spLine = [[UILabel alloc] initWithFrame:CGRectZero];
    self.spLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.contentView addSubview:self.spLine];
     __weak typeof(self)wself = self;
    [self.spLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(wself.contentLabel);
        make.height.mas_equalTo(0.8);
        make.bottom.mas_equalTo(0);
    }];
    self.spLine.hidden = YES;
}

- (void)dispalyContent:(NSString *)content lines:(NSUInteger)lines spLineShow:(BOOL)splineShow {
    self.contentLabel.text = content;
    self.contentLabel.numberOfLines = lines;
    //NSLog(@"---- content numoflines--%ld ",self.contentLabel.numberOfLines);
    if (splineShow) {
        if (self.spLine.hidden) self.spLine.hidden = NO;
    }else {
        if (!self.spLine.hidden) self.spLine.hidden = YES;
    }
}

+ (CGFloat)tagExtraWidth {
    return ([self leftSpace] + [self rightSpace] + [self dotL] + [self contentLeft]);
}

+ (CGFloat)tagFont {
    return 14.0;
}

+ (CGFloat)topSpace {
    return 10;
}

+ (CGFloat)bottomSapce {
    return 5;
}

+ (CGFloat)leftSpace {
    return 15.0;
}

+ (CGFloat)rightSpace {
    return 10.0f;
}

+ (CGFloat)dotL {
    return 18.0;
}

+ (CGFloat)contentLeft {
    return 7.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
