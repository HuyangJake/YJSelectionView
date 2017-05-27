//
//  YJSelectionView.m
//  YJSelectionView
//
//  Created by Jake on 2017/5/25.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "YJSelectionView.h"
#import "AppDelegate.h"
#define kRootWindow  ((AppDelegate*)([UIApplication sharedApplication].delegate)).window
#define kLastSelection @"YJSelectionArchive_%p"

static const CGFloat tableViewMaxHeight = 300;
static const CGFloat rowHeight = 45;

@interface YJSelectionCell : UITableViewCell
@property (nonatomic, strong) UIButton *selectionButton;
@property (nonatomic, strong) UILabel *descriptionLabel;
@end

@implementation YJSelectionCell

- (UIButton *)selectionButton {
    if (!_selectionButton) {
        _selectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectionButton setImage:[UIImage imageNamed:@"yj_selected"] forState:UIControlStateSelected];
        [_selectionButton setImage:[UIImage imageNamed:@"yj_normal"] forState:UIControlStateNormal];
        _selectionButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_selectionButton];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_selectionButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_selectionButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-15];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_selectionButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:24];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_selectionButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:24];
        [self addConstraint:trailing];
        [self addConstraint:centerY];
        [self addConstraint:width];
        [self addConstraint:height];
    }
    return _selectionButton;
}

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        [_descriptionLabel setFont:[UIFont systemFontOfSize:14]];
        [_descriptionLabel setTextColor: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0]];
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_descriptionLabel];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_descriptionLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_descriptionLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:15];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_descriptionLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:45];
        [self addConstraint:leading];
        [self addConstraint:trailing];
        [self addConstraint:centerY];
    }
    return _descriptionLabel;
}

@end


@interface YJSelectionView ()<UITableViewDelegate, UITableViewDataSource>
//Data
@property (nonatomic, strong) NSArray *optionsArray;
@property (nonatomic, strong) NSString *headerString;
@property (nonatomic, assign) BOOL isSingleSelection;//是否是单选状态
@property (nonatomic, strong) NSMutableArray *selectedArray;//已选择的index数组

@property (nonatomic, weak) id _Nullable delegate;
//UI
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *headerTitleLabel;

@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *tableViewHeight;
@property (nonatomic, strong) NSLayoutConstraint *bottomViewHeight;
@property (nonatomic, strong) NSLayoutConstraint *headerTitleHeight;
@end

@implementation YJSelectionView

+ (YJSelectionView *_Nonnull)showWithTitle:(NSString *_Nonnull)title options:(NSArray *_Nonnull)optionsArray singleSelection:(BOOL)selection delegate:(id _Nonnull)delegate completionHandler:(CompleteSelection _Nonnull)handler{
    
    YJSelectionView *view = [[YJSelectionView alloc] initWithFrame:kRootWindow.bounds];
    [kRootWindow addSubview:view];
    view.selectedArray = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:kLastSelection, delegate]] mutableCopy];
    if (!view.selectedArray) {
        view.selectedArray = [NSMutableArray new];
    }
    view.isSingleSelection = selection;
    view.delegate = delegate;
    view.canMemory = YES;
    view.completeSelection = handler;
    view.optionsArray = [optionsArray copy];
    view.headerString = title;
    
    
    [view.tableView registerClass:[YJSelectionCell class] forCellReuseIdentifier:@"Cell"];
    [view.tableView reloadData];
    
    view.tableViewHeight.constant = view.tableView.contentSize.height > tableViewMaxHeight? tableViewMaxHeight : view.tableView.contentSize.height;
    view.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    view.tableView.bounces = view.tableViewHeight.constant == tableViewMaxHeight ? YES : NO;
    view.bottomViewHeight.constant = view.tableViewHeight.constant + view.headerTitleHeight.constant + 0.5;
    [view layoutIfNeeded];
    [view showView:view];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *bgView = [[UIView alloc] initWithFrame:frame];
        bgView.backgroundColor = [UIColor colorWithRed:0.72 green:0.72 blue:0.72 alpha:0.7];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBgView:)];
        [bgView addGestureRecognizer:tap];
        self.bgView = bgView;
        [self addSubview:bgView];
        [self triggerInitialize];
        
    }
    return self;
}

#pragma mark - TableViewDelegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.optionsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YJSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.descriptionLabel.text = self.optionsArray[indexPath.row];
    cell.selectionButton.selected = NO;
    if ([self.selectedArray containsObject:@(indexPath.row)]) {
        cell.selectionButton.selected = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YJSelectionCell *cell = (YJSelectionCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isSingleSelection) {
        [self.selectedArray removeAllObjects];
        [self.selectedArray addObject:@(indexPath.row)];
        if (self.canMemory) {
            [[NSUserDefaults standardUserDefaults] setObject:self.selectedArray forKey:[NSString stringWithFormat:kLastSelection, self.delegate]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.completeSelection(indexPath.row, nil);
        [self closeView:self];
    } else {
        cell.selectionButton.selected = !cell.selectionButton.isSelected;
        if (cell.selectionButton.isSelected) {
            [self.selectedArray addObject:@(indexPath.row)];
        } else {
            [self.selectedArray removeObject:@(indexPath.row)];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
}

#pragma mark - Action

- (void)tapCancleBtn:(UIButton *)sender {
    self.completeSelection(-1, nil);
    [self closeView:self];
}

- (void)tapConfirmBtn:(UIButton *)sender {
    if (self.selectedArray.count == 0) {
        self.headerTitleLabel.text = @"请选择选项";
        return;
    }
    if (self.canMemory) {
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedArray forKey:[NSString stringWithFormat:kLastSelection, self.delegate]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.completeSelection(-100, [self.selectedArray copy]);
    [self closeView:self];
}

- (void)tapBgView:(UITapGestureRecognizer *)sender {
    self.completeSelection(-1, nil);
    [self closeView:self];
}

- (void)showView:(YJSelectionView *)view {
    view.bgView.alpha = 0;
    view.bottomConstraint.constant = CGRectGetHeight(self.bottomView.frame);
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        view.bottomConstraint.constant = 0;
        view.bgView.alpha = 0.7;
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)closeView:(YJSelectionView *)view {
    [UIView animateWithDuration:0.3 animations:^{
        view.bottomConstraint.constant = CGRectGetHeight(self.bottomView.frame);
        view.bgView.alpha = 0;
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

#pragma mark - Initlating

- (void)triggerInitialize {
    self.bottomView.alpha = 1;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.headerTitleLabel.alpha = 1;
    self.cancelBtn.userInteractionEnabled = YES;
    self.confirmBtn.userInteractionEnabled = YES;
}

- (void)setHeaderString:(NSString *)headerString {
    _headerString = headerString;
    self.headerTitleLabel.text = headerString;
    CGFloat topSpacing = headerString ? 40 : 0;
    self.headerTitleHeight.constant = topSpacing;
    self.confirmBtn.hidden = self.isSingleSelection;
    [self updateConstraintsIfNeeded];
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_bottomView];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        self.bottomConstraint = bottom;
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:rowHeight + tableViewMaxHeight];
        self.bottomViewHeight = height;
        NSArray *constantArr = @[bottom, left, right, height];
        [self addConstraints:constantArr];
        
    }
    return _bottomView;
}

- (UILabel *)headerTitleLabel {
    if (!_headerTitleLabel) {
        _headerTitleLabel = [[UILabel alloc]init];
        _headerTitleLabel.text = self.headerString;
        _headerTitleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        _headerTitleLabel.font = [UIFont systemFontOfSize:16];
        _headerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomView addSubview:_headerTitleLabel];
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_headerTitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_headerTitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_headerTitleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:30];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_headerTitleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:_bottomView attribute:NSLayoutAttributeWidth multiplier:1 constant:-30];
        self.headerTitleHeight = height;
        NSArray *constantArr = @[top, centerX, height, width];
        [_bottomView addConstraints:constantArr];
       
    }
    return _headerTitleLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomView addSubview:_tableView];
        
       
        
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:250];
        self.tableViewHeight = height;
        NSArray *constantArr = @[bottom, left, right, height];
        [_bottomView addConstraints:constantArr];
        
        UIView *topline = [[UIView alloc] init];
        topline.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        topline.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomView addSubview:topline];
        NSLayoutConstraint *left_l = [NSLayoutConstraint constraintWithItem:topline attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right_l = [NSLayoutConstraint constraintWithItem:topline attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom_l = [NSLayoutConstraint constraintWithItem:topline attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_tableView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
          NSLayoutConstraint *height_l = [NSLayoutConstraint constraintWithItem:topline attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.5];
        NSArray *constantArr_l = @[bottom_l, left_l, right_l, height_l];
        [_bottomView addConstraints:constantArr_l];
    }
    return _tableView;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.backgroundColor = [UIColor whiteColor];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelBtn setTitleColor: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(tapCancleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_cancelBtn];
        _cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
       NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_cancelBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_headerTitleLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_cancelBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:15];
        NSArray *constantArr = @[centerY, left];
        [_bottomView addConstraints:constantArr];
    }
    return _cancelBtn;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.backgroundColor = [UIColor whiteColor];
        [_confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmBtn setTitleColor: [UIColor colorWithRed:118/255.0 green:172/255.0 blue:248/255.0 alpha:1/1.0]
 forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(tapConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_confirmBtn];
        _confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_confirmBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_headerTitleLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_confirmBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15];
        NSArray *constantArr = @[centerY, right];
        [_bottomView addConstraints:constantArr];
    }
    return _confirmBtn;
}

@end
