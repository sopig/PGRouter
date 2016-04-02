//
//  JXRemoteRoute.h
//  jiuxian
//
//  Created by 张正超 on 16/3/15.
//  Copyright © 2016年 jiuxian.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//远程URL ROUTE,接收到url之后需依赖应用内 route完成route

@interface JXRemoteRoute : NSObject

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

@end
