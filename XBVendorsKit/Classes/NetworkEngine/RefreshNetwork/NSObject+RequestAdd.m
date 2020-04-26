//
//  NSObject+RequestAdd.m
//  OCEditProject
//
//  Created by Xinbo Hong on 2020/4/8.
//  Copyright © 2020 com.xinbo. All rights reserved.
//

#import "NSObject+RequestAdd.h"
#import <objc/runtime.h>
#import "NetworkConfig.h"

@implementation NSObject (RequestAdd)


static void *dataArrayKey = &dataArrayKey;
static void *orginResponseObject = &orginResponseObject;
static void *currentPage = &currentPage;
static void *isRequesting = &isRequesting;
static void *isNoMoreData = &isNoMoreData;

- (void)setDataArray:(NSMutableArray *)dataArray {
    objc_setAssociatedObject(self, &dataArray, dataArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)dataArray {
    return objc_getAssociatedObject(self, &dataArrayKey);
}

- (void)setOrginResponseObject:(id)orginResponseObject {
    objc_setAssociatedObject(self, &orginResponseObject, orginResponseObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id)orginResponseObject {
    return objc_getAssociatedObject(self, &orginResponseObject);
}

- (void)setCurrentPage:(NSInteger)currentPage {
    objc_setAssociatedObject(self, &currentPage, @(currentPage), OBJC_ASSOCIATION_ASSIGN);
}
- (NSInteger)currentPage {
    return [objc_getAssociatedObject(self, &currentPage) integerValue];
}

- (void)setIsRequesting:(BOOL)isRequesting {
    objc_setAssociatedObject(self, &isRequesting, @(isRequesting), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)isRequesting {
    return [objc_getAssociatedObject(self, &isRequesting) boolValue];
}

- (void)setIsNoMoreData:(BOOL)isNoMoreData {
    objc_setAssociatedObject(self, &isNoMoreData, @(isNoMoreData), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)isNoMoreData {
    return [objc_getAssociatedObject(self, &isNoMoreData) boolValue];
}



                             

- (RACSignal *)baseSingleRequestWithSet:(NetworkConfig *)setting {

    RACReplaySubject *subject = [RACReplaySubject subject];
    if ([self isSatisfyLoadMoreRequest]) {
        [subject sendError:nil];
        return subject;
    }

    if (!setting.paramet) {
        setting.paramet = [NSMutableDictionary dictionary];
    }
    if (!setting.isRefresh) {
        self.currentPage = 0;
    }
    self.currentPage++;
    if (setting.keyOfPage) {
        [setting.paramet setValue:@(self.currentPage) forKey:setting.keyOfPage];
    }
    self.isRequesting = NO;
    

    
}


/// 是否正在请求中
- (BOOL)isSatisfyLoadMoreRequest{
    return (!self.isNoMoreData&&!self.isRequesting);
}



@end
