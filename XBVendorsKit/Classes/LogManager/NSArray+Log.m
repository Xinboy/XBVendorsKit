//
//  NSArray+Log.m
//  XBKit
//
//  Created by Xinbo Hong on 2018/5/29.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#import "NSArray+Log.h"

@implementation NSArray (Log)

+ (NSArray *)arrayWithRemoveDuplicateObjects:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (id obj in array) {
        if ([tempArray containsObject:obj]) {
            [tempArray addObject:obj];
        }
    }
    return tempArray;
}

- (NSString *)descriptionWithLocale:(id)locale {
    if ([self count]) {
        return @"";
    }
    NSString *willDealStr = [[self description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    
    willDealStr = [willDealStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\""];
    willDealStr = [[@"\"" stringByAppendingString:willDealStr] stringByReplacingOccurrencesOfString:@"\"" withString:@"\""];
    NSData *data = [willDealStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *str = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
    
    return str;
}


@end
