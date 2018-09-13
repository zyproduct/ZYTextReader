//
//  ViewController.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ViewController.h"
#import "ZYTRViewController.h"
#import <CoreText/CoreText.h>
#import "ZYTRDataBase.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createBtn];
}

- (void)createBtn {
  
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(0, 0, 200, 50);
    btn2.center = CGPointMake(self.view.center.x, 250);
    btn2.layer.borderColor = [UIColor blackColor].CGColor;
    [btn2 setBackgroundColor:[UIColor whiteColor]];
    btn2.layer.borderWidth = 1.0;
    btn2.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor;
    btn2.layer.shadowOffset = CGSizeMake(1, 1);
    btn2.layer.shadowOpacity = 0.5;
    [btn2 setTitle:@"Reader2" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(goOtherReader:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)goOtherReader:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"book1" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic.count) {
            //arr = @[arr[0], arr[1], arr[2],];
            ZYTRViewController *vc = [[ZYTRViewController alloc] init];
            vc.keyId = @"60002_1198";
            vc.dataDic = dic;
            vc.name = @"漫长的中场休息";
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
