//
//  PayTypeCell.h
//  temp
//
//  Created by Xinbo Hong on 2019/1/12.
//  Copyright © 2019年 Xinbo. All rights reserved.
//

#import <UIKit/UIKit.h>


UIKIT_EXTERN NSString *const kIconImageNameKey;
UIKIT_EXTERN NSString *const kPayTypeNameKey;
UIKIT_EXTERN NSString *const kPayTypeDescKey;
UIKIT_EXTERN NSString *const kSelectedImageNameKey;

@interface PayTypeCell : UITableViewCell

@property (nonatomic, assign, getter=isCellSelected) BOOL cellSelected;

- (void)showWithData:(NSDictionary *)dataDict;

@end
