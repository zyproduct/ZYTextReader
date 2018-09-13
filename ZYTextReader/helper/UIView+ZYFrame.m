//
//  UIView+ZYFrame.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "UIView+ZYFrame.h"

@implementation UIView (ZYFrame)

-(CGFloat)x{
    return self.frame.origin.x;
}
-(void)setX:(CGFloat)x{
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

-(CGFloat)y{
    return self.frame.origin.y;
}
-(void)setY:(CGFloat)y{
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

-(CGFloat)height{
    return self.frame.size.height;
}
-(void)setHeight:(CGFloat)height{
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

-(CGFloat)width{
    return self.frame.size.width;
}
-(void)setWidth:(CGFloat)width{
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

@end
