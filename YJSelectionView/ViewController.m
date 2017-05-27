//
//  ViewController.m
//  YJSelectionView
//
//  Created by Jake on 2017/5/25.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "ViewController.h"
#import "YJSelectionView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}
- (IBAction)tap:(id)sender {
    [YJSelectionView showWithTitle:@"测试" options:@[@"第一行", @"第二行", @"第三"] singleSelection:YES delegate:self completionHandler:^(NSInteger index, NSArray *array) {
        NSLog(@"%ld", index);
        for (id obj in array) {
            NSLog(@"%@", obj);
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
