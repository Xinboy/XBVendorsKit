//
//  NetworkHeader.h
//  XBProjectModule
//
//  Created by Xinbo Hong on 2018/1/14.
//  Copyright © 2018年 Xinbo. All rights reserved.
//

#ifndef NetworkHeader_h
#define NetworkHeader_h
/****************** 基本参数 ******************/
#if DEBUG
#define kBaseUrl                     @"http://testapi.xiaojipuhui.com/api"
#else
#define kBaseUrl                     @"https://api.xiaobaizu.com/Api/"
#endif


static NSString *const kTokenKey = @"";
static NSString *const kAppID = @"1138676300";

#define EXPIRE_VALUE    [[NSUserDefaults standardUserDefaults] objectForKey:@"expire"]
#define TOKEN_VALUE     [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]
#define UID_VALUE       [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]



#endif /* NetworkHeader_h */
