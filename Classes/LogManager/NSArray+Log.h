//
//  NSArray+Log.h
//  XBKit
//
//  Created by Xinbo Hong on 2018/5/29.
//  Copyright © 2018年 Xinbo. All rights reserved.
//
//显示中文
#import <Foundation/Foundation.h>

@interface NSArray (Log)

/**
 删除数组中重复的数据
 
 @param array 需要删除的数组
 @return 删除完成的数组
 */
+ (NSArray *)arrayWithRemoveDuplicateObjects:(NSArray *)array;

@end
