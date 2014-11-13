//
//  A.m
//  meta_class
//
//  Created by 张正超 on 14/11/13.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "A.h"
#import <objc/runtime.h>

void TestMetaClass(id self, SEL _cmd){
    NSLog(@"this object is %p",self);
    NSLog(@"class is %@,super class is %@",[self class],[self superclass]);
    
    Class currentClass = [self class];
    
    for (int i = 0; i < 4; i++) {
        NSLog(@"following  the isa pointer %d times gives %p",i,currentClass);
        currentClass = objc_getClass((__bridge void*)currentClass);
    }
    
    NSLog(@"nsobject's class is %p",[NSObject class]);
    NSLog(@"nsobject's meta class is %p",objc_getClass((__bridge void *)[NSObject class]));
}

@implementation A

- (void)ex_registerClassPair{

    Class newClass = objc_allocateClassPair([NSError class], "TestClass", 0);
    
    class_addMethod(newClass, @selector(testMetaClass), (IMP)TestMetaClass, "v@:");
    objc_registerClassPair(newClass);
    
    id instance = [[newClass alloc]initWithDomain:@"some domain" code:0 userInfo:nil];
    
    [instance performSelector:@selector(testMetaClass)];
    
}


@end
