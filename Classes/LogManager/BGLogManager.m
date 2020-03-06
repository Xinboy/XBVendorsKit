//
//  BGLogManager.m
//
//
//  Created by Artillery on 15/6/10.
//  Copyright (c) 2015年 qianshi. All rights reserved.
//

#import "BGLogManager.h"
#import <Crashlytics/CLSLogging.h>

#define LOG_OUT  (LOG_TYPE_API | LOG_TYPE_ERROR | LOG_TYPE_NORMAL  |LOG_TYPE_UTEST | LOG_TYPE_MONITOR | LOG_TYPE_DEBUG)
@implementation BGLogManager

static BGLogManager *logManager = nil;

- (instancetype)init{
    self = [super init];
    _logType = LOG_OUT;    
    return self;
}

+ (instancetype)global{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logManager = [[BGLogManager alloc] init];
    });
    return logManager;
}


//多参数输出
+ (void)log:(LOG_TYPE)type file:(NSString *)file line:(NSInteger)line farmat:(NSString *)farmat,...{
    NSString *logStr ;
    va_list params; //定义一个指向个数可变的参数列表指针；
    va_start(params,farmat);//va_start  得到第一个可变参数地址,
    if (farmat) {
        logStr = [[NSString alloc] initWithFormat:farmat arguments:params];
    }
    va_end(params);
    
    if (logStr == nil && farmat != nil) {
        logStr = [logStr stringByAppendingFormat:farmat,@"nil"];
    }else if(logStr == nil && farmat == nil){
        return;
    }
    if (!logStr) {
        return;
    }
    if ([BGLogManager global].enableLog) {
        [[BGLogManager global] log:logStr type:type file:file line:line];
    }
}

- (NSString *)getTypeString:(LOG_TYPE)type{
    NSString *str = @"";
    switch (type) {
            case LOG_TYPE_API:
            str = @"[API]";
            break;
            case LOG_TYPE_ERROR:
            str = @"[ERROR]";
            break;
            case LOG_TYPE_UTEST:
            str = @"[UnitTest]";
            break;
            case LOG_TYPE_MONITOR:
            str = @"[MONITOR]";
            break;
            case LOG_TYPE_DEBUG:
            str = @"[DEBUG]";
            break;
        default:
            break;
    }
    return str;
}

- (void)log:(NSString *)str type:(LOG_TYPE)type file:(NSString *)file line:(NSInteger)line{
    
    if ([BGLogManager global].logType & type) {
        
        NSString *logStr = [[[BGLogManager global] getTypeString:type] stringByAppendingString:str];
        
        logStr = [[NSString stringWithFormat:@"[%@:%lu]",file,line] stringByAppendingString:logStr];

#ifdef DEBUG
        /**输出时间头**/
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"[yyyy-MM-dd HH:mm:ss:SSS]"];
        NSString *date =  [dateFormat stringFromDate:[NSDate date]];
        printf("[%s]%s\n\n",date.UTF8String,logStr.UTF8String);
#endif
        switch (type) {
            case LOG_TYPE_API:
            case LOG_TYPE_ERROR:
            case LOG_TYPE_NORMAL:{
                CLSLog(@"%@\n",logStr);
                break;
            }
            default:
                break;
        }
    }
}

+(void)logNotFatalError:(NSString *)domain withMsg:(NSString *)msg {
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:msg forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:domain code:777 userInfo:details];
    [[Crashlytics sharedInstance] recordError:error];
}

+(void)logFatalError:(NSString *)domain withMsg:(NSString *)msg {
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:msg forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:domain code:999 userInfo:details];
    [[Crashlytics sharedInstance] recordError:error];
}



@end
