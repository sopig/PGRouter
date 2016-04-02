//
//  JXRouterPlist.h
//  jiuxian
//
//  Created by 张正超 on 16/1/4.
//  Copyright © 2016年 jiuxian.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXRouterPlist : NSObject

/**
 * 公共页跳转
 */
@property (nonatomic , strong) NSString * _Nullable jxurl;


+ (nonnull instancetype)plist;

- (nullable NSArray *)loadPlists;


@end
