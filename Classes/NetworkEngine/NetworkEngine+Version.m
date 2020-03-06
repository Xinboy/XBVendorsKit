//
//  NetworkEngine+Version.m
//  XBVendorsKit
//
//  Created by Xinbo Hong on 2019/11/28.
//

#import "NetworkEngine+Version.h"


@implementation NetworkEngine (Version)

+ (NSString *)stringWithAppLocalVersion {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Info.plist" ofType:nil];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    return version;
}

//根据服务器信息检查 App Store 版本
+ (void)showHasNewVersionUpdates {
    //获取本地版本
    //去掉.
    NSString *oldStr = [[self stringWithAppLocalVersion] stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    [NetworkEngine basedGetNoTokenRequestWithUrl:@"version" Params:nil requestCount:0 response:^(id resposObject) {
        NSDictionary *dataDict = resposObject[@"data"];
        NSString *newStr = [dataDict[@"version"] stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        if ([newStr intValue] > [oldStr intValue]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"有新版本可供更新" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
                    [task resume];
                    
                });
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
    } failed:^(NSString *failedObject) {
        
    }];
    
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

@end
