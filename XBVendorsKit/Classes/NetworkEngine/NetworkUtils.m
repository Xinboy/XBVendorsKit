//
//  NetworkUtils.m
//  OCEditProject
//
//  Created by Xinbo Hong on 2020/3/6.
//  Copyright © 2020 com.xinbo. All rights reserved.
//

#import "NetworkUtils.h"
#import <AFNetworking.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CommonCrypto/CommonDigest.h>
#import <yy>


static NSString *const kAppID = @"";
@implementation NetworkUtils

+ (NSString *)md5StringFromUrlString:(NSString *)string {
    NSParameterAssert(string != nil && string.length > 0);
    
    const char *value = string.UTF8String;
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

+ (NSString *)currentTimeStampS {
    return [self currentTimeForamt:@"YYYY-MM-dd HH:mm:ss"];
}

+ (NSString *)currentTimeStampMS {
    return [self currentTimeForamt:@"YYYY-MM-dd HH:mm:ss SSS"];
}

+ (NSMutableDictionary *)parameterExchange:(NetworkConfig *)setting {
    //拼接url参数
    NSString *urlWithParameterString = setting.hostUrl;
    NSArray *dictKeysArray = setting.paramet.allKeys;
    
    if (dictKeysArray.count > 0) {
        //对 key 进行排序
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        NSComparator sort = ^(NSString *obj1,NSString *obj2){
            NSRange range = NSMakeRange(0,obj1.length);
            return [obj1 compare:obj2 options:comparisonOptions range:range];
        };
        NSArray *resultArray = [dictKeysArray sortedArrayUsingComparator:sort];
        urlWithParameterString = [urlWithParameterString stringByAppendingString:@"?"];
        for (NSString *key in resultArray) {
            urlWithParameterString = [urlWithParameterString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, [setting.paramet objectForKey:key]]];
        }
        urlWithParameterString = [urlWithParameterString substringToIndex:urlWithParameterString.length - 1];
    }
    NSLog(@"\n\n路径--%@", urlWithParameterString);
    return setting.paramet;
}

+ (NSString *)cacheFilePath:(NetworkConfig *)setting {
    NSString *requestInfo = [NSString stringWithFormat:@"%@%@",setting.hostUrl, setting.paramet];
    NSString *cacheFileName = [self md5StringFromUrlString:requestInfo];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

+ (NSInteger)compareFileAvailability:(NetworkConfig *)setting {
    return [self compareCurrentTime:[self getCurrentTime:setting] withFileCreatTime:[self getFileCreateTime:setting]];
}

/// 如果没达到指定日期返回-1，刚好是这一时间，返回0，否则返回1
+ (NSInteger)compareCurrentTime:(NSDate *)currentTime withFileCreatTime:(NSDate *)fileCreatTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSString *currentStr = [dateFormatter stringFromDate:currentTime];
    NSString *fileStr = [dateFormatter stringFromDate:fileCreatTime];
    NSDate *currentDate = [dateFormatter dateFromString:currentStr];
    NSDate *fileDate = [dateFormatter dateFromString:fileStr];
    NSComparisonResult result = [currentDate compare:fileDate];
    
    NSLog(@"currentTime : %@ \nfileCreatTime : %@", currentTime, fileCreatTime);
    
    NSInteger aa = 0;
    if (result == NSOrderedDescending) {
        //文件创建时间超过当前时间,刷新数据
        aa = 1;
    }else if (result == NSOrderedAscending){
        //文件创建时间小于当前时间,返回缓存数据
        aa = -1;
    }
    return aa;
    
}

+ (void)saveCashDataForArchiver:(id)responseData requestSeting:(NetworkConfig *)seting {
    NSString *path = [self cacheFilePath:seting];
    if (responseData != nil) {
        @try {
            if (seting.jsonValidator) {
                //如果有格式验证就进行验证
                BOOL result = [NetworkUtils validateJSON:responseData withValidator:seting.jsonValidator];
                if (result) {
                    [NSKeyedArchiver archiveRootObject:responseData toFile:path];
                } else {
                    //格式不正确
                    NSFileManager *manager = [NSFileManager defaultManager];
                    //检测文件路径存不存在
                    BOOL isFileExist = [manager fileExistsAtPath:path isDirectory:nil];
                    if (isFileExist) {
                        //如果文件存在,肯定是老数据,把文件删掉
                        NSError *error = nil;
                        [manager removeItemAtPath:path error:&error];
                    }
                }
            } else {
                //没有验证直接存储
                [NSKeyedArchiver archiveRootObject:responseData toFile:path];
            }
        } @catch (NSException *exception) {
            NSLog(@"Save cache failed, reason = %@", exception.reason);
        }
    }
}

+ (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator {
    if ([json isKindOfClass:[NSDictionary class]] &&
        [jsonValidator isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = json;
        NSDictionary * validator = jsonValidator;
        BOOL result = YES;
        NSEnumerator *enumerator = [validator keyEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSArray class]]) {
                result = [self validateJSON:value withValidator:format];
                if (!result) {
                    break;
                }
            } else {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([json isKindOfClass:[NSArray class]] &&
               [jsonValidator isKindOfClass:[NSArray class]]) {
        NSArray *validatorArray = (NSArray *)jsonValidator;
        if (validatorArray.count > 0) {
            NSArray * array = json;
            NSDictionary * validator = jsonValidator[0];
            for (id item in array) {
                BOOL result = [self validateJSON:item withValidator:validator];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
        
    } else if ([json isKindOfClass:jsonValidator]) {
        return YES;
    } else {
        return NO;
    }
}



#pragma mark - --- 网络状态情况 ---
+ (BOOL)isEnableWIFI {
    YYRe
}
/**
 WiFi：获取WiFi信息
 
 @return WiFi信息
 */
+ (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    return info;
}
/**
 *  网络监测(在什么网络状态)
 *
 *  @param unknown          未知网络
 *  @param reachable        无网络
 *  @param reachableViaWWAN 蜂窝数据网
 *  @param reachableViaWiFi WiFi网络
 */
- (void)networkStatusUnknown:(Unknown)unknown
                   reachable:(Reachable)reachable
            reachableViaWWAN:(ReachableViaWWAN)reachableViaWWAN
            reachableViaWiFi:(ReachableViaWiFi)reachableViaWiFi;
{
    // 创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 监测到不同网络的情况
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                unknown();
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                reachable();
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机自带网络");
                reachableViaWWAN();
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                reachableViaWiFi();
                break;
                
            default:
                break;
        }
    }] ;
    [manager startMonitoring];
}


#pragma mark - --- App 版本比对 ---
+ (NSString *)stringWithAppLocalVersion {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Info.plist" ofType:nil];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    return version;
}

//检查 App Store 版本, 不依赖各种第三方, 采用原生
+ (void)showHasNewVersionUpdate {
    
    //获取本地版本
    //去掉.
    NSString *oldStr = [[self stringWithAppLocalVersion] stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    //    下载链接
    //    https://itunes.apple.com/us/app/iqup/id1149168206?mt=8
    NSString *appURLStr = @"http://itunes.apple.com/lookup?id=";
    NSString *appIDStr = kAppID;
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", appURLStr, appIDStr];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSError *err = nil;
            NSDictionary *appInfoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
            if (err) {
                NSLog(@"%@",err);
                return;
            }
            NSArray *resultArray = [appInfoDict objectForKey:@"results"];
            if (![resultArray count]) {
                NSLog(@"error : resultArray == nil");
                return;
            }
            NSDictionary *infoDict = [resultArray objectAtIndex:0];
            NSString *newStr = [[infoDict objectForKey:@"version"] stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            if ([newStr intValue] > [oldStr intValue]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"有新版本可供更新" message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSString *updateUrl = [[infoDict objectForKey:@"trackViewUrl"] stringByReplacingOccurrencesOfString:@"https" withString:@"itms-apps"];
                    
                    NSString *systemV = [UIDevice currentDevice].systemVersion;
                    if (systemV.doubleValue >= 10.0) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl] options:@{} completionHandler:^(BOOL success) {
                            
                        }];
                    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
#pragma clang diagnostic pop
                    }
                    
                }];
                [alertController addAction:okAction];
                //!!!!!!!后期加入可获取的 是否强制更新变量
                if (1) {
                    //选择更新
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [alertController addAction:cancelAction];
                }
                //强制更新
                [[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers.lastObject presentViewController:alertController animated:YES completion:nil];
            }
            
        }];
        [task resume];
    });
    
}


#pragma mark - --- Private ---

+ (NSString *)currentTimeForamt:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:format];
    
    //设置时区,这个对于时间的处理有时很重要(当前手机所在时区)
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *dateNow = [NSDate new];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[dateNow timeIntervalSince1970]*1000];
    return timeSp;
}

+ (NSString *)cacheBasePath {
    //放入cash文件夹下,为了让手机自动清理缓存文件,避免产生垃圾
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![manager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [manager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
    return path;
}

+ (void)createBaseDirectoryAtPath:(NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:path withIntermediateDirectories:YES attributes:nil error:&error];
}


+ (NSDate *)getCurrentTime:(NetworkConfig *)setting {
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSString *dateTime=[formatter stringFromDate:[NSDate date]];
    NSDate *date = [formatter dateFromString:dateTime];
    NSTimeInterval time = (setting.cashTime == 0 ? 3 * 60 : setting.cashTime * 60);
    NSDate *currentTime = [date dateByAddingTimeInterval:-time];
    return currentTime;
    
}

+ (NSDate *)getFileCreateTime:(NetworkConfig *)setting{
    
    NSString *path = [self cacheFilePath:setting];
    NSError * error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //通过文件管理器来获得属性
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
    NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
    return fileCreateDate;
    
}
@end
