//
//  JXURLMap.h
//  jiuxian
//
//  Created by 张正超 on 16/3/21.
//  Copyright © 2016年 jiuxian.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//wap站 --> 映射到 native Url
@interface JXURLMap : NSObject

- (NSURL *)map:(NSURL *)url;

@end
