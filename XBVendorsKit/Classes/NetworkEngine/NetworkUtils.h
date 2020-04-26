//
//  NetworkUtils.h
//  OCEditProject
//
//  Created by Xinbo Hong on 2020/3/6.
//  Copyright © 2020 com.xinbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkConfig.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^ _Nullable Unknown)(void);          // 未知网络状态的Block
typedef void (^ _Nullable Reachable)(void);        // 无网络的Blcok
typedef void (^ _Nullable ReachableViaWWAN)(void); // 蜂窝数据网的Block
typedef void (^ _Nullable ReachableViaWiFi)(void); // WiFi网络的Block

@interface NetworkUtils : NSObject

/// 路径进行md5加密
+ (NSString *)md5StringFromUrlString:(NSString *)string;

/// 时间戳秒
+ (NSString *)currentTimeStampS;
/// 时间戳毫秒
+ (NSString *)currentTimeStampMS;


/// 生成sign加密串,时间戳,授权码
/// @param setting 网络请求参数设置
+ (NSMutableDictionary *)parameterExchange:(NetworkConfig *)setting;


/// 缓存目录路径
/// @param setting 网络请求参数设置
+ (NSString *)cacheFilePath:(NetworkConfig *)setting;


/// 比较当前时间与缓存本地文件时间 -1 文件没有过期; 0 时间刚好相等; 1 文件已过期需要刷新数据
/// @param setting 网络请求参数设置
+ (NSInteger)compareFileAvailability:(NetworkConfig *)setting;


/// 比较当前时间与文件创建时间 -1 文件没有过期; 0 时间刚好相等; 1 文件已过期需要刷新数据
/// @param currentTime 当前时间
/// @param fileCreatTime 文件创建时间
+ (NSInteger)compareCurrentTime:(NSDate *)currentTime
              withFileCreatTime:(NSDate *)fileCreatTime;

/// 将请求数据保存到本地
/// @param responseData 当前请求数据
/// @param seting 网络请求的配置
+ (void)saveCashDataForArchiver:(id)responseData
                 requestSeting:(NetworkConfig *)seting;




/// 将原数据进行json字段类型检验 YES 要检测的字段类型符合; NO 反之
/// @param json 请求下来的原数据
/// @param jsonValidator 要检验的json字段类型
+ (BOOL)validateJSON:(id)json
       withValidator:(id)jsonValidator;


#pragma mark - --- 网络状态情况 ---
/// wifi网络是否可用
+ (BOOL)isEnableWIFI;



/// 蜂窝数据是否可用
+ (BOOL)isEnableWWAN;


/// 当前网络状态是否可用
+ (BOOL) isNoNet;



/// WiFi：获取WiFi信息
+ (id)fetchSSIDInfo;


/// 网络监测(在什么网络状态)并处理
/// @param unknown 未知网络
/// @param reachable 无网络
/// @param reachableViaWWAN 蜂窝数据网
/// @param reachableViaWiFi WiFi网络
- (void)networkStatusUnknown:(Unknown)unknown
                   reachable:(Reachable)reachable
            reachableViaWWAN:(ReachableViaWWAN)reachableViaWWAN
            reachableViaWiFi:(ReachableViaWiFi)reachableViaWiFi;

#pragma mark - --- App 版本比对 ---

/// 本地App版本
+ (NSString *)stringWithAppLocalVersion;

/// 检查 App Store 版本, 不依赖各种第三方, 采用原生请求
+ (void)showHasNewVersionUpdate;
@end

NS_ASSUME_NONNULL_END
