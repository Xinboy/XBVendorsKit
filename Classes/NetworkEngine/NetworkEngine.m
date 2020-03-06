//
//  NetworkEngine.m
//  XBProjectModule
//
//  Created by Xinbo Hong on 2018/1/1.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#import "NetworkEngine.h"
#import <AdSupport/AdSupport.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AFNetworking.h>
@interface NetworkEngine ()

@property (nonatomic, assign, getter=isGettingToken) BOOL gettingToken;

/// 包含Token的网络请求队列,Token失效会取消所有操作
@property (nonatomic, strong) NSOperationQueue *tokenNetQueue;

/// 非包含Token的网络请求队列
@property (nonatomic, strong) NSOperationQueue *normalNetQueue;
@end


@implementation NetworkEngine
#pragma mark - --- Public Function ---
+ (void)fetchToken {
    [self fetchTokenWithIndex:0];
}

#pragma mark - **************** 判断网络状态方法
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



+ (NetworkStatus)networkStatuWithCurrent {
    switch ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        case NotReachable:
            return NotReachable;
        case ReachableViaWWAN:
            return ReachableViaWWAN;
        case ReachableViaWiFi:
            return ReachableViaWiFi;
    }
}


#pragma mark - **************** 网络请求相关方法
/**
 获取token （同步请求）2次退出
 */
+ (void)fetchTokenWithIndex:(NSInteger)requestCount {
    //正在获取token
    [NetworkEngine sharedInstance].gettingToken = true;
    NSString *urlStr = [NSString stringWithFormat:@"%@/Oauth/get_token.html",kBaseUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    //小白租的POST参数设定
    NSString *token_key = @"xbz_20170824#u8p";
    NSString *adID = [[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *adIDEn = @"12333";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"appid"] = adIDEn;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 5.0;
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
    
    [manager POST:urlStr parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"----");

        //保存token和过期时间
        if ([responseObject[@"code"] isEqual: @"0000"])  {
            NSUserDefaults *UserDefault = [NSUserDefaults standardUserDefaults];
            [UserDefault setValue:responseObject[@"data"][@"expire"] forKey:@"expire"];
            [UserDefault setValue:responseObject[@"data"][@"token"] forKey:@"token"];
            
            //更新参数后，继续请求
            [NetworkEngine sharedInstance].gettingToken = false;
            [NetworkEngine sharedInstance].tokenNetQueue.suspended = NO;
            
        } else {
            //重新请求
            [self fetchTokenWithIndex:requestCount + 1];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"token error");
        if (requestCount > 2) {
            if (error.code == -1001) {
                //[SVProgressHUD showErrorWithStatus:@"网络差，请重试" dismissWithDelay:kDismissTime];
            }
            UITabBarController *vc = [UIApplication sharedApplication].keyWindow.rootViewController.tabBarController;
            vc.selectedIndex = 2;
            
            //多次获取Token失败，终止所有请求
            [NetworkEngine sharedInstance].gettingToken = false;
            [[NetworkEngine sharedInstance].tokenNetQueue cancelAllOperations];
            return;
        } else {
            //重新请求
            [self fetchTokenWithIndex:requestCount + 1];
        }
    }];
}


+ (void)basedPOSTRequestWithUrl:(NSString *)url
                         params:(NSMutableDictionary *)params
                        isToken:(BOOL)isNeedToken
                   requestCount:(NSInteger)count
                       response:(void (^)(id resposObject))response
                         failed:(void (^)(NSString *failedObject))failed {
    
    if (isNeedToken) {
        NSDate *currentDate = [NSDate date];
        NSTimeInterval time = [currentDate timeIntervalSince1970];
        if (([EXPIRE_VALUE integerValue] > time || !EXPIRE_VALUE) && [NetworkEngine sharedInstance].isGettingToken == false) {
            // token无效或过期
            [NetworkEngine sharedInstance].tokenNetQueue.suspended = YES;
            [self fetchToken];
        } else {
            [NetworkEngine sharedInstance].tokenNetQueue.suspended = NO;
        }
    }
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        NSString *reqUrl = [NSString stringWithFormat:@"%@/%@",kBaseUrl,url];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 5.0;
        
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        
        //加入token
        [manager.requestSerializer setValue:TOKEN_VALUE forHTTPHeaderField:@"authorization"];
        
        [manager POST:reqUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *jsonDict = responseObject;
            NSLog(@"responseObject info:%@\nmsg:%@",jsonDict,jsonDict[@"message"]);
            if ([jsonDict[@"error_code"] integerValue] == 200 || [jsonDict[@"error_code"] integerValue] == 0) {
                response(jsonDict);
            } else if ([jsonDict[@"error_code"] integerValue] == 422) {
                failed(jsonDict[@"message"]);
            } else {
                //其他code情况处理
                //[SVProgressHUD showErrorWithStatus:jsonDict[@"message"] dismissWithDelay:kDismissTime];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
            NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
            NSString *dataStr = [[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *temp = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:temp options:NSJSONReadingMutableLeaves error:nil];
            if ([[jsonDict allKeys] containsObject:@"error_code"]) {
                if ([jsonDict[@"error_code"] integerValue] == 200 || [jsonDict[@"error_code"] integerValue] == 0) {
                    response(jsonDict);
                } else if ([jsonDict[@"error_code"] integerValue] == 422) {
                    failed(jsonDict[@"message"]);
                } else if ([jsonDict[@"error_code"] integerValue] == 401) {
                    //未登录
                    failed(jsonDict[@"message"]);
                } else {
                    if (count > 2) {
                        //多次请求失败，终止所有请求
                        if (isNeedToken) {
                            [[NetworkEngine sharedInstance].tokenNetQueue cancelAllOperations];
                        } else {
                            [[NetworkEngine sharedInstance].normalNetQueue cancelAllOperations];
                        }
                        return;
                    } else {
                        //重新请求
                        [self basedPOSTRequestWithUrl:url params:params isToken:isNeedToken requestCount:count + 1 response:response failed:failed];
                    }
                }
            } else {
                if ([dataStr containsString:@"html"]) {
                    response(dataStr);
                } else {
                    if (count > 2) {
                        //多次请求失败，可能网络问题或者其他问题导致，终止所有请求
                        if (error.code == -1001) {
                            //[SVProgressHUD showErrorWithStatus:@"网络差，请重试" dismissWithDelay:kDismissTime];
                        }
                        if (isNeedToken) {
                            [[NetworkEngine sharedInstance].tokenNetQueue cancelAllOperations];
                        } else {
                            [[NetworkEngine sharedInstance].normalNetQueue cancelAllOperations];
                        }
                        
                        return;
                    } else {
                        //重新请求
                        [self basedPOSTRequestWithUrl:url params:params isToken:isNeedToken requestCount:count + 1 response:response failed:failed];
                    }
                }
            }
        }];
    }];
    if (isNeedToken) {
        [[NetworkEngine sharedInstance].tokenNetQueue addOperation:op];
    } else {
        [[NetworkEngine sharedInstance].normalNetQueue addOperation:op];
    }
    
    
}



+ (void)basedGETRequestWithUrl:(NSString *)url
                         params:(NSMutableDictionary *)params
                        isToken:(BOOL)isNeedToken
                   requestCount:(NSInteger)count
                       response:(void (^)(id resposObject))response
                         failed:(void (^)(NSString *failedObject))failed  {
    
    if (isNeedToken) {
        NSDate *currentDate = [NSDate date];
        NSTimeInterval time = [currentDate timeIntervalSince1970];
        if (([EXPIRE_VALUE integerValue] > time || !EXPIRE_VALUE) && [NetworkEngine sharedInstance].isGettingToken == false) {
            // token无效或过期
            [NetworkEngine sharedInstance].tokenNetQueue.suspended = YES;
            [self fetchToken];
        } else {
            [NetworkEngine sharedInstance].tokenNetQueue.suspended = NO;
            //将队列中的所有请求都替换Token
        }
    }
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        NSString *reqUrl = [NSString stringWithFormat:@"%@/%@",kBaseUrl,url];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 5.0;
        [manager.requestSerializer setValue:TOKEN_VALUE forHTTPHeaderField:@"authorization"];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        
        [manager GET:reqUrl parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *jsonDict = responseObject;
            NSLog(@"responseObject info:%@\nmsg:%@",jsonDict,jsonDict[@"message"]);
            if ([jsonDict[@"error_code"] integerValue] == 200 || [jsonDict[@"error_code"] integerValue] == 0) {
                response(jsonDict);
            } else if ([jsonDict[@"error_code"] integerValue] == 422) {
                failed(jsonDict[@"message"]);
            } else {
                //其他code情况处理
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
            NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
            NSString *dataStr = [[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *temp = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:temp options:NSJSONReadingMutableLeaves error:nil];
            if ([[jsonDict allKeys] containsObject:@"error_code"]) {
                if ([jsonDict[@"error_code"] integerValue] == 200 || [jsonDict[@"error_code"] integerValue] == 0) {
                    response(jsonDict);
                } else if ([jsonDict[@"error_code"] integerValue] == 422) {
                    failed(jsonDict[@"message"]);
                } else if ([jsonDict[@"error_code"] integerValue] == 401) {
                    //未登录
                    failed(jsonDict[@"message"]);
                } else {
                    if (count > 2) {
                        //多次请求失败，终止所有请求
                        if (isNeedToken) {
                            [[NetworkEngine sharedInstance].tokenNetQueue cancelAllOperations];
                        } else {
                            [[NetworkEngine sharedInstance].normalNetQueue cancelAllOperations];
                        }
                        return;
                    } else {
                        //重新请求
                        [self basedGETRequestWithUrl:url params:params isToken:isNeedToken requestCount:count + 1 response:response failed:failed];
                    }
                }
            } else {
                if ([dataStr containsString:@"html"]) {
                    response(dataStr);
                } else {
                    if (count > 2) {
                        //多次请求失败，可能网络问题或者其他问题导致，终止所有请求
                        if (error.code == -1001) {
                            //[SVProgressHUD showErrorWithStatus:@"网络差，请重试" dismissWithDelay:kDismissTime];
                        }
                        if (isNeedToken) {
                            [[NetworkEngine sharedInstance].tokenNetQueue cancelAllOperations];
                        } else {
                            [[NetworkEngine sharedInstance].normalNetQueue cancelAllOperations];
                        }
                        
                        return;
                    } else {
                         //重新请求
                        [self basedGETRequestWithUrl:url params:params isToken:isNeedToken requestCount:count + 1 response:response failed:failed];
                    }
                }
            }
        }];
        
    }];
    
    if (isNeedToken) {
        [[NetworkEngine sharedInstance].tokenNetQueue addOperation:op];
    } else {
        [[NetworkEngine sharedInstance].normalNetQueue addOperation:op];
    }
    
    
}

#pragma mark - --- lazy ---
- (NSOperationQueue *)tokenNetQueue {
    if (!_tokenNetQueue) {
        self.tokenNetQueue = [[NSOperationQueue alloc] init];
    }
    return _tokenNetQueue;
}

- (NSOperationQueue *)normalNetQueue {
    if (!_normalNetQueue) {
        self.normalNetQueue = [[NSOperationQueue alloc] init];
    }
    return _normalNetQueue;
}

- (BOOL)isGettingToken {
    if (!_gettingToken) {
        self.gettingToken = false;
    }
    return _gettingToken;
}

#pragma mark - --- 单例 ---

static NetworkEngine *kSingleObject = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSingleObject = [[super allocWithZone:NULL] init];
    });
    return kSingleObject;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copy {
    return kSingleObject;
}

- (id)mutableCopy {
    return kSingleObject;
}

@end
