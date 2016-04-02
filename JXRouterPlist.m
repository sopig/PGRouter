//
//  JXRouterPlist.m
//  jiuxian
//
//  Created by 张正超 on 16/1/4.
//  Copyright © 2016年 jiuxian.com. All rights reserved.
//

#import "JXRouterPlist.h"

@implementation JXRouterPlist
+ (instancetype)plist {
    static id __plist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __plist = [[self class] new];
    });
    return __plist;
}

+ (NSArray *)propertyName {
    unsigned int count;
    NSMutableArray *value = [NSMutableArray new];
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        [value addObject:[NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding]];
        CLog(@"name:%s", property_getName(property));
        CLog(@"attributes:%s", property_getAttributes(property));
        
    }
    free(properties);
    return [value copy];
}

- (NSArray *)loadPlists {
    
    NSArray *plistNames = [[JXRouterPlist propertyName] copy];
    NSMutableArray *paths = [NSMutableArray array];
    [plistNames enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *path = [[NSBundle mainBundle] pathForResource:obj ofType:@"plist"];
        NSAssert(path, ([NSString stringWithFormat:@"检查%@plist配置文件是否正确", obj, nil]));
        [paths addObject:path];
    }];
    
    return [paths copy];
    
}

@end
