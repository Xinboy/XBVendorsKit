//
//  NetworkConfig.h
//  OCEditProject
//
//  Created by Xinbo Hong on 2020/4/8.
//  Copyright © 2020 com.xinbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN
@class NetworkConfig;
@interface NetWorkRequestModel : NSObject

+ (RACSignal *)networkRequestSeting:(NetworkConfig *)setting;

+ (RACSignal *)uploadWithImagesInSeting:(NetworkConfig *)setting;
@end

NS_ASSUME_NONNULL_END

