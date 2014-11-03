//
//  todayTableViewCell.m
//  TodayWidget
//
//  Created by HMT on 14/10/28.
//  Copyright (c) 2014年 MTH. All rights reserved.
//

#import "TodayTableViewCell.h"

@implementation TodayTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.isShowRight = NO;
    [self.didCopyLabel setTextColor:[UIColor whiteColor]];
    [self.rightEnterButton setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    [self.leftImageButton setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didClickRightEnterButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(transViewAction:)]) {
        [self.delegate transViewAction:self];
    }
}

- (IBAction)didClickDeleteButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(deleteClipBoardCell:)]) {
        [self.delegate deleteClipBoardCell:self];
    }
}

- (IBAction)didClickSendButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(sendClipBoardContent:)]) {
        [self.delegate sendClipBoardContent:self];
    }
}

- (IBAction)didClickMoreButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(enterContainingApp)]) {
        [self.delegate enterContainingApp];
    }
}

- (IBAction)didClickMakeTureButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(makeTureContent:)]) {
        [self.delegate makeTureContent:self];
    }
}

@end
