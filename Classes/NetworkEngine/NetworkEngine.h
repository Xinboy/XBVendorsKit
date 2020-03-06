//
//  NetworkEngine.h
//  XBProjectModule
//
//  Created by Xinbo Hong on 2018/1/1.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "NetworkHeader.h"
@interface NetworkEngine : NSObject



+ (instancetype)sharedInstance;
#pragma mark - **************** 判断网络状态方法
/**
 WiFi：获取WiFi信息
 
 @return WiFi信息
 */
+ (id)fetchSSIDInfo;

/**
 Network：获取当前网络状况
 
 @return 网络状况：0,无网络 1,DATA流量 2,WiFi
 */
+ (NetworkStatus)networkStatuWithCurrent;

#pragma mark - **************** 网络请求相关方法

/// 获取token会暂停当前队列所有需要Token的请求
+ (void)fetchToken;



/// Post网络请求
/// @param url URL地址
/// @param params 请求参数
/// @param isNeedToken 是否需要Token
/// @param count 该请求的当前请求次数（如果只需请求一次，请传2）
/// @param response 成功Block
/// @param failed 失败Block
+ (void)basedPOSTRequestWithUrl:(NSString *)url
                          params:(NSMutableDictionary *)params
                         isToken:(BOOL)isNeedToken
                    requestCount:(NSInteger)count
                        response:(void (^)(id resposObject))response
                         failed:(void (^)(NSString *failedObject))failed;
@end




@interface XBRequestModel : NSObject

/** 重试的剩余次数 */
@property (nonatomic, assign) NSInteger times;

/** 请求类型 */
@property (nonatomic, assign) RequestType requestType;

/** 请求url */
@property (nonatomic, strong) NSString *urlStr;

/** 请求参数 */
@property (nonatomic, strong) NSDictionary *params;

/** upload时的数组 */
@property (nonatomic, strong) NSArray *formDataArray;

/** 是否在请求 */
@property (nonatomic, assign) BOOL isRequesting;

@end
————————————————
版权声明：本文为CSDN博主「H.A.N」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/u010960265/article/details/82905867
