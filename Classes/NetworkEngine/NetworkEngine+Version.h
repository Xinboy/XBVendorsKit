//
//  NetworkEngine+Version.h
//  XBVendorsKit
//
//  Created by Xinbo Hong on 2019/11/28.
//



#import "NetworkEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkEngine (Version)


/// 本地App版本
+ (NSString *)stringWithAppLocalVersion;


/// 根据服务器信息检查 App Store 版本
+ (void)showHasNewVersionUpdates;


//检查 App Store 版本, 不依赖各种第三方, 采用原生请求
+ (void)showHasNewVersionUpdate;
@end

NS_ASSUME_NONNULL_END
