//
//  NSDictionary+Log.m
//  XBCodingRepo
//
//  Created by Xinbo Hong on 2018/5/15.
//  Copyright © 2018年 Xinbo Hong. All rights reserved.
//
//显示中文
#import "NSDictionary+Log.h"

@implementation NSDictionary (Log)

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
