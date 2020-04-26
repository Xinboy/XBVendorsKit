//
//  NetworkEngine.h
//  XBProjectModule
//
//  Created by Xinbo Hong on 2018/1/1.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkHeader.h"
@interface NetworkEngine : NSObject



+ (instancetype)sharedInstance;

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


/// 根据服务器信息检查 App Store 版本
+ (void)showHasNewVersionUpdates;

@end




@interface XBRequestModel : NSObject

/** 重试的剩余次数 */
@property (nonatomic, assign) NSInteger times;

/** 请求类型 */
//@property (nonatomic, assign) RequestType requestType;

/** 请求url */
@property (nonatomic, strong) NSString *urlStr;

/** 请求参数 */
@property (nonatomic, strong) NSDictionary *params;

/** upload时的数组 */
@property (nonatomic, strong) NSArray *formDataArray;

/** 是否在请求 */
@property (nonatomic, assign) BOOL isRequesting;

@end

