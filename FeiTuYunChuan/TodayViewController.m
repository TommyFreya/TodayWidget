//
//  TodayViewController.m
//  TodayExtension
//
//  Created by HMT on 14/10/28.
//  Copyright (c) 2014年 MTH. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TodayTableViewCell.h"
#import "FTWidgetClipModel.h"

@interface TodayViewController () <NCWidgetProviding,FTTranViewViewDelegate>

@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) UIButton *leftImageButton;
@property (nonatomic, strong) NSMutableArray *allDataArray;
@property (nonatomic, copy) NSString *lastPasteBoard;
@property (nonatomic, strong) NSMutableDictionary *hideStateDic;

@end

@implementation TodayViewController

static NSString *const KArchiverKey = @"DataArray";
static NSString *const KArchiverLastClipKey = @"LastClipKey";
static NSString *const KHideStateKey = @"HideStateKey";
static const NSTimeInterval kCopyAnimationDuration = 0.6;
static const NSTimeInterval kTranAnimationDuration = 0.5;
static const NSTimeInterval KUpAndDownAnimationDuration = 0.3;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    self.hideStateDic = [NSMutableDictionary dictionary];
    self.headButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.leftImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // 数据处理(需要固化)
    NSUserDefaults *sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.tranfer"];
    NSData *unarchiverData = [sharedUserDefaults objectForKey:KArchiverKey];
    // 特别注意,[NSKeyedUnarchiver unarchiveObjectWithData:unarchiverData] 转化的是一个数组,因为我固化的是一个数组
    // PS:allDataArray 的类型 是 NSMutableArray
    // 不能直接用self.allDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:unarchiverData];
    self.allDataArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:unarchiverData]];
    NSData *lastStringData = [sharedUserDefaults objectForKey:KArchiverLastClipKey];
    self.lastPasteBoard = [NSKeyedUnarchiver unarchiveObjectWithData:lastStringData];
    
    // 系统剪切板
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setPersistent:YES];
    if (pasteboard.string && ![pasteboard.string isEqualToString:self.lastPasteBoard]) {
        FTWidgetClipModel *widgetClip = [[FTWidgetClipModel alloc] init];
        widgetClip.userName = [[UIDevice currentDevice] name];
        widgetClip.content = pasteboard.string;
        widgetClip.clipTime = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        widgetClip.isTure = @"False";
        if (self.allDataArray.count >= 1 && self.allDataArray.count < 5 ) {
            [self.allDataArray insertObject:widgetClip atIndex:0];
        } else if (self.allDataArray.count == 5){
            [self.allDataArray removeObjectAtIndex:4];
            [self.allDataArray insertObject:widgetClip atIndex:0];
        } else {
            [self.allDataArray addObject:widgetClip];
        }
        
        // 固化数据
        [self _saveDataToSanBoxWithDataArray:_allDataArray];
        self.lastPasteBoard = pasteboard.string;
        [self _saveLastClipboard:_lastPasteBoard];
        
        [self.hideStateDic setObject:@"隐藏最近剪辑" forKey:KHideStateKey];
        } else {
    }
    
    if (self.allDataArray.count == 0 || !pasteboard.string) {
        [self.hideStateDic setObject:@"没有复制任何内容" forKey:KHideStateKey];
    } else {
        [self.hideStateDic setObject:@"隐藏最近剪辑" forKey:KHideStateKey];
    }
    
    // 调整高度
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 400-72*(5 - _allDataArray.count));
    
    //[self _showOrHideHeadSectionAction];
}

#pragma mark - NCWidgetProviding Method
// 一般默认的View是从图标的右边开始的...如果你想变换,就要实现这个方法
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    //UIEdgeInsets newMarginInsets = UIEdgeInsetsMake(defaultMarginInsets.top, defaultMarginInsets.left - 16, defaultMarginInsets.bottom, defaultMarginInsets.right);
    //return newMarginInsets;
    //return UIEdgeInsetsZero; // 完全靠到了左边....
    return UIEdgeInsetsMake(0.0, 16.0, 0, 0);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.allDataArray.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodatTableViewCell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        FTWidgetClipModel *clipModel = self.allDataArray[indexPath.row];
        cell.nameLabel.text = clipModel.userName;
        cell.timeLabel.text = [self _dealShowTimeWithModelTime: [clipModel.clipTime doubleValue] withNowTime:[[NSDate date] timeIntervalSince1970]];
        cell.belongRow = indexPath.row;
        if ([clipModel.isTure isEqualToString:@"True"] ) {
            cell.contentLabel.alpha = 1.0;
            cell.rightEnterButton.alpha = 1.0;
            cell.addBackView.alpha = 0.0;
            cell.contentLabel.text = clipModel.content;
        } else {
            cell.contentLabel.alpha = 0.0;
            cell.rightEnterButton.alpha = 0.0;
            cell.addBackView.alpha = 1.0;
            cell.addContentLabel.text = clipModel.content;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.isShowRight = YES;
        }
    }
    // 点进按钮弹出右边视图(没用block,用的delegate)
    cell.delegate = self;
    return cell;
}

// 点击左右视图切换按钮
- (void)transViewAction:(TodayTableViewCell *)todayCell {
    if (todayCell.isShowRight == NO) {
        [UIView animateWithDuration:kTranAnimationDuration animations:^{
            todayCell.backView.transform = CGAffineTransformTranslate(todayCell.backView.transform, -todayCell.frame.size.width, 0);
            todayCell.rightBackView.transform = CGAffineTransformTranslate(todayCell.rightBackView.transform, -todayCell.frame.size.width, 0);
        }];
        todayCell.isShowRight = YES;
    } else {
        [UIView animateWithDuration:kTranAnimationDuration animations:^{
            todayCell.backView.transform = CGAffineTransformTranslate(todayCell.backView.transform, todayCell.frame.size.width, 0);
            todayCell.rightBackView.transform = CGAffineTransformTranslate(todayCell.rightBackView.transform, todayCell.frame.size.width, 0);
        }];
        todayCell.isShowRight = NO;
    }
}

// 点击More按钮
- (void)enterContainingApp {
    [self.extensionContext openURL:[NSURL URLWithString:@"appextension://123"] completionHandler:^(BOOL success) {
                     NSLog(@"open url result:%d",success);
    }];
}

// 点击删除按钮
- (void)deleteClipBoardCell:(TodayTableViewCell *)todayCell {
    [self.allDataArray removeObjectAtIndex:todayCell.belongRow];
    if (self.allDataArray.count == 0) {
        [self.hideStateDic setObject:@"没有复制任何内容" forKey:KHideStateKey];
    }
    [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self setPreferredContentSize:CGSizeMake(self.view.bounds.size.width, 400-72*(5 - _allDataArray.count))];
    // 删除后记得重新保存数据
    [self _saveDataToSanBoxWithDataArray:_allDataArray];
    
}

// 点击add按钮
- (void)makeTureContent:(TodayTableViewCell *)todayCell {
    FTWidgetClipModel *clipModel = self.allDataArray[todayCell.belongRow];
    clipModel.isTure = @"True";
    todayCell.isShowRight = NO;
    todayCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    [self _saveDataToSanBoxWithDataArray:_allDataArray];
    [self.mainTableView reloadData];
}

// 点击发送按钮
- (void)sendClipBoardContent:(TodayTableViewCell *)todayCell {
    todayCell.deleteButton.alpha = 0.0;
    todayCell.sendButton.alpha = 0.0;
    todayCell.moreButton.alpha = 0.0;
    
    
}

#pragma mark - UITableViewDelegate Methods
// section头部的height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 40;
    }
}

// section头部的view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        
        _headButton.frame = CGRectMake(-48, 0, 240, 40);
        [_headButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _headButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_headButton setTitle:[_hideStateDic objectForKey:KHideStateKey] forState:UIControlStateNormal];
        [_headButton addTarget:self action:@selector(didClickHeadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:_headButton];
        
        _leftImageButton.frame = CGRectMake(0, 8, 20, 20);
        [_leftImageButton setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        [_leftImageButton addTarget:self action:@selector(didClickHeadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:_leftImageButton];
        if ([[self.hideStateDic objectForKey:KHideStateKey] isEqualToString:@"没有复制任何内容"]) {
            _leftImageButton.alpha = 0.0;
        } else {
            _leftImageButton.alpha = 1.0;
        }
        return headView;
    }
}

- (void)didClickHeadButtonAction:(UIButton *)btn {
    [self _showOrHideHeadSectionAction];
}

// cell被选中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 选中cell后,高亮状态立马就消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TodayTableViewCell *cell = (TodayTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    // copy的动画效果
    if (cell.isShowRight == NO) {
        cell.backView.alpha = 0.0;
        [UIView animateWithDuration:kCopyAnimationDuration animations:^{
            [UIView animateWithDuration:kCopyAnimationDuration animations:^{
                cell.didCopyLabel.transform = CGAffineTransformMakeScale(1.3, 1.3);
            }];
            cell.didCopyLabel.alpha = 1.0;
            cell.userInteractionEnabled = NO;
        } completion:^(BOOL finished) {
            cell.backView.alpha = 1.0;
            cell.didCopyLabel.alpha = 0.0;
            cell.didCopyLabel.transform = CGAffineTransformIdentity;
            cell.userInteractionEnabled = YES;
        }];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setPersistent:YES];
        pasteboard.string = cell.contentLabel.text;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

#pragma mark - Private Methods
// 显示/隐藏按钮的响应方法
- (void)_showOrHideHeadSectionAction {
    if ([[self.hideStateDic objectForKey:KHideStateKey] isEqualToString:@"没有复制任何内容"]) {
    } else {
        NSUserDefaults *sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.tranfer"];
        if ([[self.hideStateDic objectForKey:KHideStateKey] isEqualToString:@"隐藏最近剪辑"]) {
            [self.allDataArray removeAllObjects];
            [UIView animateWithDuration:KUpAndDownAnimationDuration animations:^{
                [self setPreferredContentSize:CGSizeMake(self.view.bounds.size.width, 40)];
                self.leftImageButton.transform = CGAffineTransformRotate(self.leftImageButton.transform, M_PI);
            }];
            [self.hideStateDic setObject:@"显示最近剪辑" forKey:KHideStateKey];
            // 记得刷新
            [self.mainTableView reloadData];
        } else {
            NSData *unarchiverData = [sharedUserDefaults objectForKey:KArchiverKey];
            self.allDataArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:unarchiverData]];
            [UIView animateWithDuration:KUpAndDownAnimationDuration animations:^{
                [self setPreferredContentSize:CGSizeMake(self.view.bounds.size.width, 400-72*(5 - _allDataArray.count))];
                self.leftImageButton.transform = CGAffineTransformRotate(self.leftImageButton.transform, M_PI);
            }];
            [self.hideStateDic setObject:@"隐藏最近剪辑" forKey:KHideStateKey];
            [self.mainTableView reloadData];
        }
    }
}

// 保存主数据
- (void)_saveDataToSanBoxWithDataArray:(NSMutableArray *)dataArray {
    NSUserDefaults *sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.tranfer"];
    NSData *archiverData = [NSKeyedArchiver archivedDataWithRootObject:dataArray];
    [sharedUserDefaults setObject:archiverData forKey:KArchiverKey];
    // 切莫忘记,依旧调用 synchronize 立即写入沙盒中
    [sharedUserDefaults synchronize];
}

// 保存剪切板最新的记录
- (void)_saveLastClipboard:(NSString *)lastString {
    NSUserDefaults *sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.tranfer"];
    NSData *archiverData = [NSKeyedArchiver archivedDataWithRootObject:lastString];
    [sharedUserDefaults setObject:archiverData forKey:KArchiverLastClipKey];
    // 切莫忘记,依旧调用 synchronize 立即写入沙盒中
    [sharedUserDefaults synchronize];
}

// 时间处理
- (NSString *)_dealShowTimeWithModelTime:(double)oldTime withNowTime:(double)nowTime {
    NSString *time = @"";
    double gap = (nowTime - oldTime) / 60.0;
    if (gap < 1.0) {
        time = @"刚刚";
    } else if (gap  >= 1.0 && gap < 60) {
        time = [NSString stringWithFormat:@"%.0f分钟",gap];
    } else if ( gap >= 60 ) {
        time = [NSString stringWithFormat:@"%.0f小时",gap/60];
    }
    return time;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    NSLog(@"%s", __func__);
    completionHandler(NCUpdateResultNewData);
}


@end
