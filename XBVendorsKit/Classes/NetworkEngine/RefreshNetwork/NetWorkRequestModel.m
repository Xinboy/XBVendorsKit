//
//  NetworkConfig.m
//  OCEditProject
//
//  Created by Xinbo Hong on 2020/4/8.
//  Copyright © 2020 com.xinbo. All rights reserved.
//

#import "NetWorkRequestModel.h"
#import "NetworkUtils.h"
#import "NetworkConfig.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking.h>
@implementation NetWorkRequestModel

+ (RACSignal *)networkRequestSeting:(NetworkConfig *)setting {
    RACReplaySubject *subject = [RACReplaySubject subject];

    setting.paramet = [NetworkUtils parameterExchange:setting];
    __block MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    HUD.animationType = MBProgressHUDAnimationFade;
    if (setting.HUDLabelText) {
        HUD.label.text = setting.HUDLabelText;
    }
    [HUD showAnimated:YES];
    HUD.hidden = setting.isHidenHUD;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:10.0];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
    response.removesKeysWithNullValues = YES;
    manager.responseSerializer = response;
    
    if (setting.isHttpsRequest) {
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"" ofType:@"cer"];
        NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
        NSSet *cerSet = [[NSSet alloc] initWithObjects:cerData, nil];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        // 是否允许,NO-- 不允许无效的证书
        [securityPolicy setAllowInvalidCertificates:NO];
        // 设置证书
        [securityPolicy setValidatesDomainName:YES];
        [securityPolicy setPinnedCertificates:cerSet];
        manager.securityPolicy = securityPolicy;
    }
    if (setting.cashSetting == NetCacheStrategyNoSave) {
        switch (setting.requestStytle) {
            //默认,不缓存,比如登录
            case NetRequesttMethodGET:
                break;
            case NetRequesttMethodPOST: {
                [[self requestManager:manager requestSet:setting progressHUD:HUD] subscribeNext:^(id  _Nullable x) {
                    [subject sendNext:x];
                } error:^(NSError * _Nullable error) {
                    [subject sendError:error];
                } completed:^{
                    [subject sendCompleted];
                }];
                break;
            }
        }
        
    } else {
        switch (setting.requestStytle) {
            case NetRequesttMethodGET:
                break;
            case NetRequesttMethodPOST: {
                // 有缓存
                //设置了缓存,如果没有设置缓存时间,默认3分钟缓存时间
                NSString *path = [NetworkUtils cacheFilePath:setting];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                //检测文件路径存不存在
                BOOL isFileExist = [fileManager fileExistsAtPath:path isDirectory:nil];
                // 如果没有网络
                if ([NetworkUtils isNoNet]) {
                    if (isFileExist) {
                        // 如果有本地缓存
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            id noNetData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
                            [subject sendNext:noNetData];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [HUD performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.0];
                            });

                        });
                    } else {
                        [HUD performSelector
                         :@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
                        [subject sendError:nil];
                    }
                } else {
                    if (isFileExist && ! setting.isRefresh) {
                        //上拉加载更多,且文件存在
                        //将本地文件取出
                        id data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
                        NSInteger time = [NetworkUtils compareFileAvailability:setting];
                        if (time == 1) {
                            [[self requestManager:manager requestSet:setting progressHUD:HUD] subscribeNext:^(id  _Nullable x) {
                                [subject sendNext:x];
                            } error:^(NSError * _Nullable error) {
                                [subject sendError:error];
                            } completed:^{
                                [subject sendCompleted];
                            }];
                        } else {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [subject sendNext:data];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [HUD performSelector
                                     :@selector(removeFromSuperview) withObject:nil afterDelay:0.0];
                                    [subject sendCompleted];
                                });
                            });
                        }
                    } else {
                        [[self requestManager:manager requestSet:setting progressHUD:HUD] subscribeNext:^(id  _Nullable x) {
                            [subject sendNext:x];
                        } error:^(NSError * _Nullable error) {
                            [subject sendError:error];
                        }completed:^{
                            [subject sendCompleted];
                        }];
                    }
                }
            }
        }
    }
    return subject;
}


+ (RACSignal *)uploadWithImagesInSeting:(NetworkConfig *)setting {
    RACReplaySubject *subject = [RACReplaySubject subject];
    __block NSMutableArray *tempArray;
//    __block int tmp_
    
    return subject;
}


#pragma mark - --- Private Method ---
+ (RACSignal *)requestManager:(AFHTTPSessionManager *)manager
                   requestSet:(NetworkConfig *)setting
                  progressHUD:(MBProgressHUD *)HUD {
    RACReplaySubject *subject = [RACReplaySubject subject];
    [manager POST:setting.hostUrl parameters:setting.paramet progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (setting.cashSetting == NetCacheStrategySave) {
                    // 无论上拉加载、下拉刷、缓存更多和刷新都没设置,都进行设置
                    [self saveCacheData:responseObject requestSetting:setting];
                }
                //有字段校验
                if (setting.jsonValidator) {
                    BOOL result = [NetworkUtils validateJSON:responseObject withValidator:setting.jsonValidator];
                    if (result) {
                        [subject sendNext:responseObject];
                    }
                } else {
                    [subject sendNext:responseObject];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HUD performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.0];
                });
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        HUD.animationType = MBProgressHUDModeText;
         HUD.label.text = @"请求失败,重新发送请求";
//         if (!setting.isHidenHUD) {
//
//         }
        [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
        [subject sendError:error];
        [subject sendCompleted];
    }];
    return subject;
}


+ (void)saveCacheData:(id)responseData requestSetting:(NetworkConfig *)setting {
    [NetworkUtils saveCashDataForArchiver:responseData requestSeting:setting];
}


@end
