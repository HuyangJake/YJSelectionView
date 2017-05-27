//
//  ViewController2.m
//  YJSelectionView
//
//  Created by Jake on 2017/5/27.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "ViewController2.h"
#import "YJSelectionView.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)tap:(id)sender {
    [YJSelectionView showWithTitle:@"test" options:@[@"jake", @"1", @"2", @"3"] singleSelection:NO delegate:self  completionHandler:^(NSInteger index, NSArray * _Nullable options) {
        NSLog(@"%ld", index);
        for (id obj in options) {
            NSLog(@"%@", obj);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
