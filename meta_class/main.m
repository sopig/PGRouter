//
//  main.m
//  meta_class
//
//  Created by 张正超 on 14/11/13.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
       
        A *aobj = [[A alloc]init];
        
        
        [aobj ex_registerClassPair];
        
        
    }
    return 0;
}
