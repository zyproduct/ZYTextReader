//
//  NYTPhotoData.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/9/12.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYTPhoto.h"

@interface NYTPhotoData : NSObject<NYTPhoto>

@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end
