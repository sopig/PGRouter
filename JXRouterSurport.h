//
//  JXRouterSurport.h
//  jiuxian
//
//  Created by 张正超 on 16/1/5.
//  Copyright © 2016年 jiuxian.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXRouter.h"
#import "JXRouterPlist.h"

typedef enum JXRouterType{
    JXRouterTypeNone,
    JXRouterTypePush,
    JXRouterTypePresent,
} JXRouterType;


@interface JXRouterSurport : NSObject

+ (instancetype)router;

//存所有的页面和url映射关系
- (void)mapUrls;

@end
