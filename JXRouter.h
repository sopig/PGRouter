//
//  JXRouter.h
//  jiuxian
//
//  Created by 张正超 on 16/1/4.
//  Copyright © 2016年 jiuxian.com. All rights reserved.
//


//1.如果需要自己操作跳转  -->
//2.参数  jxrouter
//3.跳转方式   push present  自定义
//4.过滤页
//5.页面注册名字分类

#import <Foundation/Foundation.h>


//route 类型
typedef NS_ENUM(NSInteger, JXRouteType){
    JXRouteTypeNone = 0,
    JXRouteTypeController = 1,
    JXRouteTypeBlock = 2
} ;

typedef id(^JXRouterBlock)(NSDictionary *params);


@interface JXRouter : NSObject

+ (instancetype)router;

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass;  //存映射关系到vc

- (__kindof UIViewController *)matchController:(NSString *)route;  //通过url获取带参数的vc

- (void)map:(NSString *)route toBlock:(JXRouterBlock)block; //存映射关系到block

- (JXRouterBlock)matchBlock:(NSString *)route; //获得带参数的block

- (id)callBlock:(NSString *)route;  //调用block

- (JXRouteType)canRoute:(NSString *)route;  //检查是否能够route,返回能够route到的类型

@end


@interface UIViewController (JXRoute)

@property (nonatomic, strong) NSDictionary *params;

@end
