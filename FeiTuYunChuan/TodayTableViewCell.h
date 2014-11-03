//
//  todayTableViewCell.h
//  TodayWidget
//
//  Created by HMT on 14/10/28.
//  Copyright (c) 2014年 MTH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TodayTableViewCell;
@protocol FTTranViewViewDelegate <NSObject>

@optional
- (void)transViewAction:(TodayTableViewCell *)todayCell;
- (void)enterContainingApp;
- (void)deleteClipBoardCell:(TodayTableViewCell *)todayCell;
- (void)makeTureContent:(TodayTableViewCell *)todayCell;
- (void)sendClipBoardContent:(TodayTableViewCell *)todayCell;
@end

@interface TodayTableViewCell : UITableViewCell

// 主视图
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *didCopyLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightEnterButton;

// add视图
@property (weak, nonatomic) IBOutlet UIView *addBackView;
@property (weak, nonatomic) IBOutlet UILabel *addContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

// 辅助
@property (nonatomic, assign) id<FTTranViewViewDelegate> delegate;
@property (nonatomic, assign) BOOL isShowRight;
@property (nonatomic, assign) NSUInteger belongRow;
@property (nonatomic, copy) NSString *isTureNeed;

// 右边视图
@property (weak, nonatomic) IBOutlet UIView *rightBackView;
@property (weak, nonatomic) IBOutlet UIButton *leftImageButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end
