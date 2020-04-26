//
//  NetworkConfig.h
//  OCEditProject
//
//  Created by Xinbo Hong on 2020/4/8.
//  Copyright © 2020 com.xinbo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 缓存设置
typedef NS_ENUM(NSUInteger, NetCacheStrategy) {
    /// 不缓存数据
    NetCacheStrategyNoSave = 0,
    /// 缓存数据
    NetCacheStrategySave,
};

/// 网络请求方式
typedef NS_ENUM(NSUInteger, NetRequesttMethod) {
    /// POST请求
    NetRequesttMethodPOST = 0,
    /// GET请求
    NetRequesttMethodGET = 1,
};

@interface NetworkConfig : NSObject

/// 是否显示HUD,默认显示
@property (nonatomic, assign) BOOL isHidenHUD;
/// HUD提示语
@property (nonatomic, strong)  NSString *HUDLabelText;
/// 是否是HTTPS请求,默认是NO
@property (nonatomic, assign) BOOL isHttpsRequest;
/// 缓存设置策略
@property (nonatomic, assign) NetCacheStrategy cashSetting;
/// 是否刷新数据
@property (nonatomic, assign) BOOL isRefresh;
/// 是否缓存多页数据
@property (nonatomic, assign) BOOL isCashMoreData;
/// 缓存时间
@property (nonatomic, assign) NSInteger cashTime;
/// 请求方式,默认POST请求
@property (nonatomic, assign) NetRequesttMethod requestStytle;
/// 地址
@property (nonatomic, strong) NSString *hostUrl;
/// 参数
@property (nonatomic, strong) NSMutableDictionary *paramet;
/// 验证json格式
@property (nonatomic, strong) id jsonValidator;
/// 预缓存的 model
@property (nonatomic, strong) NSString *modelNameOfArray;
/// 预缓存的数据位置
@property (nonatomic, strong) NSString *modelLocalPath;
/// 预缓存的page
@property (nonatomic, strong) NSString *keyOfPage;
/// 上传图片数组
@property (nonatomic, strong) NSArray *uploadImages;

@end

NS_ASSUME_NONNULL_END
