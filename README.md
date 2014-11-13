Runtime_1-class-instance-
=========================

运行时之一，类与对象

通过创建一个A对象，在运行时创建一个新的类 newClass 这个类继承自NSError ，
主要的代码操作是 在运行时创建的这个类，然后给这个类添加一个testMetaClass方法，
而这个方法的实现是TestMetaClass方法。



  Class newClass = objc_allocateClassPair([NSError class],"TestClass",0);
  
  运行时创建NSError的子类 ，子类名称是TestClass   ，
  
  
  class_addMethod(newClass,@selector(testMetaClass),(IMP)TestMetaClass,"v@:");
  
  给newClass这个类添加方法  SEL    testMetaClass    selector对应的实现函数是TestMetaClass
  
  objc_registerClassPair(newClass);   将运行时创建的这个类注册
  
  运行时实例化这个类    
  id instance = [[newClass alloc]initWithDomain:@"some domain" code:0 userInfo:nil];//NSError实例化方法
  
 [ instance performSelector:@selector(testMetaClass)];
  
  
  
  
  


