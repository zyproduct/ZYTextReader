//
//  ZYTRData.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRData.h"
#import "ZYTextLayout.h"

@interface ZYTRData ()

@end

@implementation ZYTRData

- (void)setCtFrame:(CTFrameRef)ctFrame {
    ZYCFSAFESETVALUEA(ctFrame, _ctFrame);
}

- (void)createLayout {
    _layout = [ZYTextLayout layoutWithFrame:_ctFrame convertHeight:_height];
}

- (void)setContent:(NSAttributedString *)content {
    _content = content;
}

-(void)dealloc{
    ZYCFSAFERELEASE(_ctFrame);
}
@end
