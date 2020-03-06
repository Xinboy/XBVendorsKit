//
//  AppDelegate+JPush.m
//  XBKit
//
//  Created by Xinbo Hong on 2018/10/22.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#import "AppDelegate+JPush.h"

#import <JPush/JPUSHService.h>
// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用 idfa 功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

static NSString *const kJPushAppKey = @"fad5d7a5636b6b156921df78";

@interface AppDelegate ()<JPUSHRegisterDelegate>


@end


@implementation AppDelegate (JPush)

//放置在application: didFinishLaunchingWithOptions:
- (void)registerJPush:(NSDictionary *)launchOptions {
//    添加初始化 APNs 代码
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert | JPAuthorizationOptionNone | JPAuthorizationOptionBadge | JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //do something...
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
//    添加初始化 JPush 代码
    // 获取 IDFA
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //注册JPush,根据实际值
    NSString *appKey = kJPushAppKey;
//    NSString *channel = @"";
    BOOL isProduction = false;
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:nil
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /*
     * Required - 注册 DeviceToken
     * JPush 3.0.9 之前的版本，必须调用此接口，注册 token 之后才可以登录极光，使用通知和自定义消息功能。
     * 从 JPush 3.0.9 版本开始，不调用此方法也可以登录极光。但是不能使用 APNs 通知功能，只可以使用 JPush 自定义消息。
     */
    [JPUSHService registerDeviceToken:deviceToken];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //实现注册 APNs 失败接口（可选）
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark --- JPUSHRegisterDelegate ---

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
    completionHandler(UNNotificationPresentationOptionAlert);
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    // 系统要求执行这个方法
    completionHandler();
}



@end
