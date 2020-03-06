//
//  MJRefreshStateHeader+Extension.m
//  XJPH
//
//  Created by Xinbo Hong on 2018/7/26.
//  Copyright © 2018年 Xinbo. All rights reserved.
//
//
//#import "MJRefreshStateHeader+Extension.h"
//
//@implementation MJRefreshStateHeader (Extension)
//
//- (void)placeSubviews
//{
//    [super placeSubviews];
//    
//    if (self.stateLabel.hidden) return;
//    
//    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;
//    self.mj_h = MJRefreshHeaderHeight + kStatusBarHeight();
//    if (self.lastUpdatedTimeLabel.hidden) {
//        // 状态
//        if (noConstrainsOnStatusLabel) self.stateLabel.frame = self.bounds;
//    } else {
//        CGFloat stateLabelH = MJRefreshHeaderHeight * 0.5;
//        // 状态
//        if (noConstrainsOnStatusLabel) {
//            self.stateLabel.mj_x = 0;
//            self.stateLabel.mj_y = kStatusBarHeight();
//            self.stateLabel.mj_w = self.mj_w;
//            self.stateLabel.mj_h = stateLabelH;
//        }
//        
//        // 更新时间
//        if (self.lastUpdatedTimeLabel.constraints.count == 0) {
//            self.lastUpdatedTimeLabel.mj_x = 0;
//            self.lastUpdatedTimeLabel.mj_y = stateLabelH + kStatusBarHeight();
//            self.lastUpdatedTimeLabel.mj_w = self.mj_w;
//            self.lastUpdatedTimeLabel.mj_h = self.mj_h - self.lastUpdatedTimeLabel.mj_y;
//        }
//    }
//}
//
//@end
