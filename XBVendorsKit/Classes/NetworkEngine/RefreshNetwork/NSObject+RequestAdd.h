//
//  NSObject+RequestAdd.h
//  OCEditProject
//
//  Created by Xinbo Hong on 2020/4/8.
//  Copyright © 2020 com.xinbo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@class NetworkConfig;
@interface NSObject (RequestAdd)

/// 数据数组
@property (nonatomic, strong) NSMutableArray *dataArray;
/// 原始请求数据
@property (nonatomic, strong) id orginResponseObject;
/// 当前页码
@property (nonatomic, assign) NSInteger currentPage;
/// 是否请求中
@property (nonatomic, assign) BOOL isRequesting;
/// 是否数据加载完
@property (nonatomic, assign) BOOL isNoMoreData;

- (RACSignal *)singalForSingleRequestWithSet:(NetworkConfig *)setting;

@end

NS_ASSUME_NONNULL_END
