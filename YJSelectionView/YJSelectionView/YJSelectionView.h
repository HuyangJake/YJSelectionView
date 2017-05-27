//
//  YJSelectionView.h
//  YJSelectionView
//
//  Created by Jake on 2017/5/25.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 选择完成后的回调

 @param index 单选状态时返回的位置（点击取消返回为-1, options为nil）
 @param options 多选状态时返回的数组（index返回为-100）
 */
typedef void (^CompleteSelection)(NSInteger index, NSArray * _Nullable options);

@interface YJSelectionView : UIView

@property (nonatomic, copy, nonnull) void (^completeSelection)(NSInteger index, NSArray * _Nullable options);

@property (nonatomic, assign) BOOL canMemory;// 是否记忆这次的选择在下次打开后展示 默认为YES

/**
 展示选择栏

 @param title 标题
 @param optionsArray 选项数组
 @param selection 是否单选  YES：单选   NO：多选
 @param delegate 若项目中用到多个此控件务必传入delegate
 @return 选择视图
 */
+ (YJSelectionView *_Nonnull)showWithTitle:(NSString *_Nonnull)title options:(NSArray *_Nonnull)optionsArray singleSelection:(BOOL)selection delegate:(id _Nonnull )delegate completionHandler:(CompleteSelection _Nonnull)handler;

@end
