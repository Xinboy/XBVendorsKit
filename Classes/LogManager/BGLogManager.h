//
//  BGLogManager.h
//
//  Created by Artillery on 15/6/10.
//  Copyright (c) 2015年 qianshi. All rights reserved.
//  控制台日志输出

#import <Foundation/Foundation.h>
#define LOGFILE @"logfile.log"
#define NSLog(format, ...) _BGLOG(LOG_TYPE_DEBUG,format,## __VA_ARGS__);

#ifdef DEBUG
#define _BGLOG(type,str,...) [BGLogManager log:type file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ farmat:str,## __VA_ARGS__]
#define BGLOG(x, ...) _BGLOG(LOG_TYPE_NORMAL,x,## __VA_ARGS__)
#define BGLOG_API(x, ...) _BGLOG(LOG_TYPE_API,[x removeEncoding],## __VA_ARGS__)
#define BGLOG_ERROR(x, ...) _BGLOG(LOG_TYPE_ERROR,x,## __VA_ARGS__)
#define BGLOG_UTEST(x, ...) _BGLOG(LOG_TYPE_UTEST,x,## __VA_ARGS__)
#define BGLOG_MONITOR(x, ...) _BGLOG(LOG_TYPE_MONITOR,x,## __VA_ARGS__)
#define BGLOG_DEBUG(x, ...) _BGLOG(LOG_TYPE_DEBUG,x,## __VA_ARGS__)
#else
#define _BGLOG(type,str,...) [BGLogManager log:type file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent] line:__LINE__ farmat:str,## __VA_ARGS__]
#define BGLOG(x, ...) _BGLOG(LOG_TYPE_NORMAL,x,## __VA_ARGS__)
#define BGLOG_API(x, ...) _BGLOG(LOG_TYPE_API,[x removeEncoding],## __VA_ARGS__)
#define BGLOG_ERROR(x, ...) _BGLOG(LOG_TYPE_ERROR,x,## __VA_ARGS__)
#define BGLOG_UTEST(...)
#define BGLOG_MONITOR(...)
#define BGLOG_DEBUG(...)
#endif


@interface BGLogManager : NSObject
typedef NS_ENUM(NSInteger, LOG_TYPE){
    LOG_TYPE_API     =    1<<1,
    LOG_TYPE_ERROR   =    1<<2,
    LOG_TYPE_UTEST   =    1<<3,
    LOG_TYPE_MONITOR =    1<<4,
    LOG_TYPE_DEBUG   =    1<<5,
    LOG_TYPE_NORMAL  =    1
};

@property (assign ,nonatomic) short logType;
@property (assign ,nonatomic) BOOL enableLog;

/**
 * 通用日志输出api
 * @param type 日志类别
 * @param file 当前执行代码所在文件
 * @param line 当前行数
 * @param farmat 可变参数
 */
+ (void)log:(LOG_TYPE)type file:(NSString *)file line:(NSInteger)line farmat:(NSString *)farmat,...;
- (void)log:(NSString *)str type:(LOG_TYPE)type file:(NSString *)file line:(NSInteger)line;
+ (instancetype)global;
+ (void)logNotFatalError:(NSString *)domain withMsg:(NSString *)msg;

+ (void)logFatalError:(NSString *)domain withMsg:(NSString *)msg;

@end
