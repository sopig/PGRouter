//
//  JXURLMap.m
//  jiuxian
//
//  Created by 张正超 on 16/3/21.
//  Copyright © 2016年 jiuxian.com. All rights reserved.
//

#import "JXURLMap.h"

@implementation JXURLMap
//jiuxian://detail
- (NSURL *)map:(NSURL *)url{
    if ([url.scheme isEqualToString:@"jiuxian"]) return url;
    
    if ([url.scheme isEqualToString:@"http"]) {
        
    }
    return nil;
}

@end
