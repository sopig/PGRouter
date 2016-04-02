//
//  JXRouterSurport.m
//  jiuxian
//
//  Created by 张正超 on 16/1/5.
//  Copyright © 2016年 jiuxian.com. All rights reserved.
//

#import "JXRouterSurport.h"

#import "JXWebReqeustManage.h"

@interface JXRouterSurport ()

@property (nonatomic , strong)NSMutableDictionary *map;

@end

@implementation JXRouterSurport

+ (instancetype)router{
    static JXRouterSurport *__surport = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __surport = self.new;
    });
    return __surport;
}

- (void)mapUrls {
    NSArray *plists = [[JXRouterPlist plist] loadPlists];
    if (plists.count <= 0 || !plists) {
        return;
    }
    self.map = [[NSDictionary dictionaryWithContentsOfFile:plists[0]] mutableCopy];
    [self.map enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSAssert([key isKindOfClass:[NSString class]], @"must be string!");
        NSAssert([obj isKindOfClass:[NSString class]], @"must be string!");
       [[JXRouter router] map:obj toControllerClass:NSClassFromString(key)];
    }];
    
}


#pragma mark - setter/getter

- (NSMutableDictionary *)map{
    if (!_map) {
        _map = [NSMutableDictionary dictionary];
    }
    return _map;
}


@end
