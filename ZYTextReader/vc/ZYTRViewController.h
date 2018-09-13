//
//  ZYTRViewController.h
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/23.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYTRViewController : UIViewController

@property (nonatomic ,strong) NSDictionary *dataDic;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *keyId;

@property (nonatomic, assign) NSInteger ttsRole;

+ (instancetype)currentInstance;

- (void)showDownCidian;

@end
