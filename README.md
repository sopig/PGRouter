Runtime
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
  
  
  最后打印结果是  ：
2014-11-13 16:31:43.415 meta_class[2739:183347] this object is 0x100204d10
2014-11-13 16:31:43.416 meta_class[2739:183347] class is TestClass,super class is NSError
2014-11-13 16:31:43.417 meta_class[2739:183347] following  the isa pointer 0 times gives 0x100204af0
2014-11-13 16:31:43.417 meta_class[2739:183347] following  the isa pointer 1 times gives 0x0
2014-11-13 16:31:43.417 meta_class[2739:183347] following  the isa pointer 2 times gives 0x0
2014-11-13 16:31:43.417 meta_class[2739:183347] following  the isa pointer 3 times gives 0x0
2014-11-13 16:31:43.417 meta_class[2739:183347] nsobject's class is 0x7fff79e830f0
2014-11-13 16:31:43.417 meta_class[2739:183347] nsobject's meta class is 0x0
  
  
  在for循环中通过objc_getClass 来获取对象的isa，并将其打印出来，因此一直回溯到NSObject的meta-class。
  
  我们在一个类对象调用class方法是无法获取meta-class，他只是返回类；
  
  
  
  
  类与对象操作函数
  runtime提供美好了大量的额函数来操作类与对象，类的操作方法大部分是以class为前缀的，而对象的操作方法大部分是以 objc 或者object为前缀的
  
  类相关操作函数
  结构体objc_class 
  struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class super_class                                        OBJC2_UNAVAILABLE;
    const char *name                                         OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list *ivars                             OBJC2_UNAVAILABLE;
    struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache *cache                                 OBJC2_UNAVAILABLE;
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;


所有类相关的操作函数提供的操作方法主要是针对 objc_class这个结构体中得各个字段的

(1)类名
获取类的类名：
const char * class_getName(Class cls);


(2)父类和元类
获取类的父类
Class class_getSuperClass(Class cls);

判断给定的Class是否是一个元类
BOOL class_isMetaClass(Class cls);


(3)实例变量大小 instance_size

获取实例大小
size_t  class_getInstanceSize(Class cls);


(4)成员变量（ivars）及属性

在objc_class中，所有的成员变量、属性的信息是放在ivars中的。ivars是一个数组，数组中每个元素是指向Ivar变量信息的指针。
我们可以通过runtime丰富的函数来操作这一字段。  分为以下几类：
1.成员变量操作函数

 Ivar class_getInstanceVariable(Class cls, const char*name); //获取类中指定名称实例成员变量信息
 
 Ivar class_getClassVariable(Class cls, const char *name);//获取类成员变量的信息

 BOOL class_addIvar(__unsafe_unretained Class cls, const char *name, size_t size, uint8_t alignment, const char *types) //添加成员变量
 
 Ivar *class_copyIvarList(Class cls, unsigned int *outCount) ;//获取整个成员变量列表
 
 分析和使用
 class_getInstanceVariable 函数，他返回一个指向包含name指定 的成员变量信息的objc_ivar结构体的指针。

 class_getClassVarible函数，目前没有找到关于OC中类变量的信息，一般认为OC不支持类变量的。
 
 
OC中不支持往已存在的类中添加实例变量，因此不管是系统库提供的类还是我们自定义的类，都无法动态添加成员变量。但如果我们通过运行时来创建一个类的话，又应该如何给她添加成员变量呢？
这是我们就可以使用class_addIvar函数了。不过需要注意的是，这个方法只能在 objc_allocateClassPair函数 与objc_registerClassPair之间 调用。另外这个类也不能是元类。成员变量的按字节最小对其量是1



class_CopyIvarList函数，他返回的一个指向成员变量信息的数组，数组中每个元素是指向该成员变量信息的objc_ivar结构体的指针。这个数组不包含在父类中声明的变量。outCount指针返回数组的大小。需要注意的是，我们必须使用free()来释放这个数组


2. 属性操作函数
  
objc_property_t class_getProperty(Class cls ,const char*name); 获取指定的属性

objc)property_t * class_copyPropertyList(Class cls ,unsigned int *outcount);//获取属性列表

BOOL   class_addProperty(__unsafe_unretained Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount)  //为类添加属性。

void  class_replaceProperty(__unsafe_unretained Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount)   //替换类的属性

这一组方法也是针对Ivar来操作，不过  只操作哪些是属性的值  


3.在MAC OS X系统中，我们可以使用垃圾回收器。runtime提供了几个函数来确定一个对象的内存区域是否可以被垃圾回收器扫描，已处理strong/weak引用。  这额函数定义如下：

const unt8_t *class_getIvarLayout(Class cls);
void class_setIvarLayout(Class cls,const uint8_t *layout);
const uint8_t *class_getWeakIvarLayout(Class cls);
void class_setWeakIvarLayout(Class cls ,const uint8_t *layout);

但通常情况下，我们不需要去主动调用这些方法；在调用objc_registerClassPair时，会生成合理的布局


(5)方法。

// 添加方法
BOOL class_addMethod ( Class cls, SEL name, IMP imp, const char *types );
 
// 获取实例方法
Method class_getInstanceMethod ( Class cls, SEL name );
 
// 获取类方法
Method class_getClassMethod ( Class cls, SEL name );
 
// 获取所有方法的数组
Method * class_copyMethodList ( Class cls, unsigned int *outCount );
 
// 替代方法的实现
IMP class_replaceMethod ( Class cls, SEL name, IMP imp, const char *types );
 
// 返回方法的具体实现
IMP class_getMethodImplementation ( Class cls, SEL name );
IMP class_getMethodImplementation_stret ( Class cls, SEL name );
 
// 类实例是否响应指定的selector
BOOL class_respondsToSelector ( Class cls, SEL sel );

class_addMethod 的实现会覆盖父类的方法实现，但不会取代本类中已存在的实现，如果奔雷中包含一个同名的实现，则函数会返回NO，如果要修改已存在的实现，可以使用 method_setImplementation  一个oc方法是一个简单的C函数，他至少包含两个参数 self和 _cmd，所以我们的实现函数（IMP参数指向的函数）至少需要两个参数，如下所示：


  void myMethodIMPortant(id self,SEL _cmd)
  {
  
  }



与成员变量不同的是，我们可以为类动态添加方法，不管这个类是否已存在。

另外，参数types是一个描述传递给方法的参数类型的字符数组，这就涉及到类型编码，我们将在后面介绍。

class_getInstanceMethod、class_getClassMethod函数，与class_copyMethodList不同的是，这两个函数都会去搜索父类的实现。

class_copyMethodList函数，返回包含所有实例方法的数组，如果需要获取类方法，则可以使用class_copyMethodList(object_getClass(cls), &count)(一个类的实例方法是定义在元类里面)。该列表不包含父类实现的方法。outCount参数返回方法的个数。在获取到列表后，我们需要使用free()方法来释放它。

class_replaceMethod函数，该函数的行为可以分为两种：如果类中不存在name指定的方法，则类似于class_addMethod函数一样会添加方法；如果类中已存在name指定的方法，则类似于method_setImplementation一样替代原方法的实现。

class_getMethodImplementation函数，该函数在向类实例发送消息时会被调用，并返回一个指向方法实现函数的指针。这个函数会比method_getImplementation(class_getInstanceMethod(cls, name))更快。返回的函数指针可能是一个指向runtime内部的函数，而不一定是方法的实际实现。例如，如果类实例无法响应selector，则返回的函数指针将是运行时消息转发机制的一部分。

class_respondsToSelector函数，我们通常使用NSObject类的respondsToSelector:或instancesRespondToSelector:方法来达到相同目的。

协议(objc_protocol_list)

协议相关的操作包含以下函数：

1
2
3
4
5
6
7
8
// 添加协议
BOOL class_addProtocol ( Class cls, Protocol *protocol );
 
// 返回类是否实现指定的协议
BOOL class_conformsToProtocol ( Class cls, Protocol *protocol );
 
// 返回类实现的协议列表
Protocol * class_copyProtocolList ( Class cls, unsigned int *outCount );
class_conformsToProtocol函数可以使用NSObject类的conformsToProtocol:方法来替代。

class_copyProtocolList函数返回的是一个数组，在使用后我们需要使用free()手动释放。

版本(version)

版本相关的操作包含以下函数：

1
2
3
4
5
// 获取版本号
int class_getVersion ( Class cls );
 
// 设置版本号
void class_setVersion ( Class cls, int version );
其它

runtime还提供了两个函数来供CoreFoundation的tool-free bridging使用，即：

1
2
Class objc_getFutureClass ( const char *name );
void objc_setFutureClass ( Class cls, const char *name );
通常我们不直接使用这两个函数。

实例(Example)

上面列举了大量类操作的函数，下面我们写个实例，来看看这些函数的实例效果：


//-----------------------------------------------------------
// MyClass.h
 
@interface MyClass : NSObject @property (nonatomic, strong) NSArray *array;
 
@property (nonatomic, copy) NSString *string;
 
- (void)method1;
 
- (void)method2;
 
+ (void)classMethod1;
 
@end
 
//-----------------------------------------------------------
// MyClass.m
 
#import "MyClass.h"
 
@interface MyClass () {
    NSInteger       _instance1;
 
    NSString    *   _instance2;
}
 
@property (nonatomic, assign) NSUInteger integer;
 
- (void)method3WithArg1:(NSInteger)arg1 arg2:(NSString *)arg2;
 
@end
 
@implementation MyClass
 
+ (void)classMethod1 {
 
}
 
- (void)method1 {
    NSLog(@"call method method1");
}
 
- (void)method2 {
 
}
 
- (void)method3WithArg1:(NSInteger)arg1 arg2:(NSString *)arg2 {
 
    NSLog(@"arg1 : %ld, arg2 : %@", arg1, arg2);
}
 
@end
 
//-----------------------------------------------------------
// main.h
 
#import "MyClass.h"
#import "MySubClass.h"
#import int main(int argc, const char * argv[]) {
    @autoreleasepool {
 
        MyClass *myClass = [[MyClass alloc] init];
        unsigned int outCount = 0;
 
        Class cls = myClass.class;
 
        // 类名
        NSLog(@"class name: %s", class_getName(cls));
 
        NSLog(@"==========================================================");
 
        // 父类
        NSLog(@"super class name: %s", class_getName(class_getSuperclass(cls)));
        NSLog(@"==========================================================");
 
        // 是否是元类
        NSLog(@"MyClass is %@ a meta-class", (class_isMetaClass(cls) ? @"" : @"not"));
        NSLog(@"==========================================================");
 
        Class meta_class = objc_getMetaClass(class_getName(cls));
        NSLog(@"%s's meta-class is %s", class_getName(cls), class_getName(meta_class));
        NSLog(@"==========================================================");
 
        // 变量实例大小
        NSLog(@"instance size: %zu", class_getInstanceSize(cls));
        NSLog(@"==========================================================");
 
        // 成员变量
        Ivar *ivars = class_copyIvarList(cls, &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            NSLog(@"instance variable's name: %s at index: %d", ivar_getName(ivar), i);
        }
 
        free(ivars);
 
        Ivar string = class_getInstanceVariable(cls, "_string");
        if (string != NULL) {
            NSLog(@"instace variable %s", ivar_getName(string));
        }
 
        NSLog(@"==========================================================");
 
        // 属性操作
        objc_property_t * properties = class_copyPropertyList(cls, &outCount);
        for (int i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSLog(@"property's name: %s", property_getName(property));
        }
 
        free(properties);
 
        objc_property_t array = class_getProperty(cls, "array");
        if (array != NULL) {
            NSLog(@"property %s", property_getName(array));
        }
 
        NSLog(@"==========================================================");
 
        // 方法操作
        Method *methods = class_copyMethodList(cls, &outCount);
        for (int i = 0; i < outCount; i++) {
            Method method = methods[i];
            NSLog(@"method's signature: %s", method_getName(method));
        }
 
        free(methods);
 
        Method method1 = class_getInstanceMethod(cls, @selector(method1));
        if (method1 != NULL) {
            NSLog(@"method %s", method_getName(method1));
        }
 
        Method classMethod = class_getClassMethod(cls, @selector(classMethod1));
        if (classMethod != NULL) {
            NSLog(@"class method : %s", method_getName(classMethod));
        }
 
        NSLog(@"MyClass is%@ responsd to selector: method3WithArg1:arg2:", class_respondsToSelector(cls, @selector(method3WithArg1:arg2:)) ? @"" : @" not");
 
        IMP imp = class_getMethodImplementation(cls, @selector(method1));
        imp();
 
        NSLog(@"==========================================================");
 
        // 协议
        Protocol * __unsafe_unretained * protocols = class_copyProtocolList(cls, &outCount);
        Protocol * protocol;
        for (int i = 0; i < outCount; i++) {
            protocol = protocols[i];
            NSLog(@"protocol name: %s", protocol_getName(protocol));
        }
 
        NSLog(@"MyClass is%@ responsed to protocol %s", class_conformsToProtocol(cls, protocol) ? @"" : @" not", protocol_getName(protocol));
 
        NSLog(@"==========================================================");
    }
    return 0;
}
这段程序的输出如下：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
2014-10-22 19:41:37.452 RuntimeTest[3189:156810] class name: MyClass
2014-10-22 19:41:37.453 RuntimeTest[3189:156810] ==========================================================
2014-10-22 19:41:37.454 RuntimeTest[3189:156810] super class name: NSObject
2014-10-22 19:41:37.454 RuntimeTest[3189:156810] ==========================================================
2014-10-22 19:41:37.454 RuntimeTest[3189:156810] MyClass is not a meta-class
2014-10-22 19:41:37.454 RuntimeTest[3189:156810] ==========================================================
2014-10-22 19:41:37.454 RuntimeTest[3189:156810] MyClass's meta-class is MyClass
2014-10-22 19:41:37.455 RuntimeTest[3189:156810] ==========================================================
2014-10-22 19:41:37.455 RuntimeTest[3189:156810] instance size: 48
2014-10-22 19:41:37.455 RuntimeTest[3189:156810] ==========================================================
2014-10-22 19:41:37.455 RuntimeTest[3189:156810] instance variable's name: _instance1 at index: 0
2014-10-22 19:41:37.455 RuntimeTest[3189:156810] instance variable's name: _instance2 at index: 1
2014-10-22 19:41:37.455 RuntimeTest[3189:156810] instance variable's name: _array at index: 2
2014-10-22 19:41:37.455 RuntimeTest[3189:156810] instance variable's name: _string at index: 3
2014-10-22 19:41:37.463 RuntimeTest[3189:156810] instance variable's name: _integer at index: 4
2014-10-22 19:41:37.463 RuntimeTest[3189:156810] instace variable _string
2014-10-22 19:41:37.463 RuntimeTest[3189:156810] ==========================================================
2014-10-22 19:41:37.463 RuntimeTest[3189:156810] property's name: array
2014-10-22 19:41:37.463 RuntimeTest[3189:156810] property's name: string
2014-10-22 19:41:37.464 RuntimeTest[3189:156810] property's name: integer
2014-10-22 19:41:37.464 RuntimeTest[3189:156810] property array
2014-10-22 19:41:37.464 RuntimeTest[3189:156810] ==========================================================
2014-10-22 19:41:37.464 RuntimeTest[3189:156810] method's signature: method1
2014-10-22 19:41:37.464 RuntimeTest[3189:156810] method's signature: method2
2014-10-22 19:41:37.464 RuntimeTest[3189:156810] method's signature: method3WithArg1:arg2:
2014-10-22 19:41:37.465 RuntimeTest[3189:156810] method's signature: integer
2014-10-22 19:41:37.465 RuntimeTest[3189:156810] method's signature: setInteger:
2014-10-22 19:41:37.465 RuntimeTest[3189:156810] method's signature: array
2014-10-22 19:41:37.465 RuntimeTest[3189:156810] method's signature: string
2014-10-22 19:41:37.465 RuntimeTest[3189:156810] method's signature: setString:
2014-10-22 19:41:37.465 RuntimeTest[3189:156810] method's signature: setArray:
2014-10-22 19:41:37.466 RuntimeTest[3189:156810] method's signature: .cxx_destruct
2014-10-22 19:41:37.466 RuntimeTest[3189:156810] method method1
2014-10-22 19:41:37.466 RuntimeTest[3189:156810] class method : classMethod1
2014-10-22 19:41:37.466 RuntimeTest[3189:156810] MyClass is responsd to selector: method3WithArg1:arg2:
2014-10-22 19:41:37.467 RuntimeTest[3189:156810] call method method1
2014-10-22 19:41:37.467 RuntimeTest[3189:156810] ==========================================================
2014-10-22 19:41:37.467 RuntimeTest[3189:156810] protocol name: NSCopying
2014-10-22 19:41:37.467 RuntimeTest[3189:156810] protocol name: NSCoding
2014-10-22 19:41:37.467 RuntimeTest[3189:156810] MyClass is responsed to protocol NSCoding
2014-10-22 19:41:37.468 RuntimeTest[3189:156810] ==========================================================
动态创建类和对象

runtime的强大之处在于它能在运行时创建类和对象。

动态创建类

动态创建类涉及到以下几个函数：

1
2
3
4
5
6
7
8
// 创建一个新类和元类
Class objc_allocateClassPair ( Class superclass, const char *name, size_t extraBytes );
 
// 销毁一个类及其相关联的类
void objc_disposeClassPair ( Class cls );
 
// 在应用中注册由objc_allocateClassPair创建的类
void objc_registerClassPair ( Class cls );
objc_allocateClassPair函数：如果我们要创建一个根类，则superclass指定为Nil。extraBytes通常指定为0，该参数是分配给类和元类对象尾部的索引ivars的字节数。

为了创建一个新类，我们需要调用objc_allocateClassPair。然后使用诸如class_addMethod，class_addIvar等函数来为新创建的类添加方法、实例变量和属性等。完成这些后，我们需要调用objc_registerClassPair函数来注册类，之后这个新类就可以在程序中使用了。

实例方法和实例变量应该添加到类自身上，而类方法应该添加到类的元类上。

objc_disposeClassPair函数用于销毁一个类，不过需要注意的是，如果程序运行中还存在类或其子类的实例，则不能调用针对类调用该方法。

在前面介绍元类时，我们已经有接触到这几个函数了，在此我们再举个实例来看看这几个函数的使用。

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
Class cls = objc_allocateClassPair(MyClass.class, "MySubClass", 0);
class_addMethod(cls, @selector(submethod1), (IMP)imp_submethod1, "v@:");
class_replaceMethod(cls, @selector(method1), (IMP)imp_submethod1, "v@:");
class_addIvar(cls, "_ivar1", sizeof(NSString *), log(sizeof(NSString *)), "i");
 
objc_property_attribute_t type = {"T", "@\"NSString\""};
objc_property_attribute_t ownership = { "C", "" };
objc_property_attribute_t backingivar = { "V", "_ivar1"};
objc_property_attribute_t attrs[] = {type, ownership, backingivar};
 
class_addProperty(cls, "property2", attrs, 3);
objc_registerClassPair(cls);
 
id instance = [[cls alloc] init];
[instance performSelector:@selector(submethod1)];
[instance performSelector:@selector(method1)];
程序的输出如下：

1
2
2014-10-23 11:35:31.006 RuntimeTest[3800:66152] run sub method 1
2014-10-23 11:35:31.006 RuntimeTest[3800:66152] run sub method 1
动态创建对象

动态创建对象的函数如下：

1
2
3
4
5
6
7
8
// 创建类实例
id class_createInstance ( Class cls, size_t extraBytes );
 
// 在指定位置创建类实例
id objc_constructInstance ( Class cls, void *bytes );
 
// 销毁类实例
void * objc_destructInstance ( id obj );
class_createInstance函数：创建实例时，会在默认的内存区域为类分配内存。extraBytes参数表示分配的额外字节数。这些额外的字节可用于存储在类定义中所定义的实例变量之外的实例变量。该函数在ARC环境下无法使用。

调用class_createInstance的效果与+alloc方法类似。不过在使用class_createInstance时，我们需要确切的知道我们要用它来做什么。在下面的例子中，我们用NSString来测试一下该函数的实际效果：

1
2
3
4
5
6
7
id theObject = class_createInstance(NSString.class, sizeof(unsigned));
id str1 = [theObject init];
 
NSLog(@"%@", [str1 class]);
 
id str2 = [[NSString alloc] initWithString:@"test"];
NSLog(@"%@", [str2 class]);
输出结果是：

1
2
2014-10-23 12:46:50.781 RuntimeTest[4039:89088] NSString
2014-10-23 12:46:50.781 RuntimeTest[4039:89088] __NSCFConstantString
可以看到，使用class_createInstance函数获取的是NSString实例，而不是类簇中的默认占位符类__NSCFConstantString。

objc_constructInstance函数：在指定的位置(bytes)创建类实例。

objc_destructInstance函数：销毁一个类的实例，但不会释放并移除任何与其相关的引用。

实例操作函数

实例操作函数主要是针对我们创建的实例对象的一系列操作函数，我们可以使用这组函数来从实例对象中获取我们想要的一些信息，如实例对象中变量的值。这组函数可以分为三小类：

针对整个对象进行操作的函数，这类函数包含

1
2
3
4
5
// 返回指定对象的一份拷贝
id object_copy ( id obj, size_t size );
 
// 释放指定对象占用的内存
id object_dispose ( id obj );
有这样一种场景，假设我们有类A和类B，且类B是类A的子类。类B通过添加一些额外的属性来扩展类A。现在我们创建了一个A类的实例对象，并希望在运行时将这个对象转换为B类的实例对象，这样可以添加数据到B类的属性中。这种情况下，我们没有办法直接转换，因为B类的实例会比A类的实例更大，没有足够的空间来放置对象。此时，我们就要以使用以上几个函数来处理这种情况，如下代码所示：

1
2
3
4
NSObject *a = [[NSObject alloc] init];
id newB = object_copy(a, class_getInstanceSize(MyClass.class));
object_setClass(newB, MyClass.class);
object_dispose(a);
2.针对对象实例变量进行操作的函数，这类函数包含：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
// 修改类实例的实例变量的值
Ivar object_setInstanceVariable ( id obj, const char *name, void *value );
 
// 获取对象实例变量的值
Ivar object_getInstanceVariable ( id obj, const char *name, void **outValue );
 
// 返回指向给定对象分配的任何额外字节的指针
void * object_getIndexedIvars ( id obj );
 
// 返回对象中实例变量的值
id object_getIvar ( id obj, Ivar ivar );
 
// 设置对象中实例变量的值
void object_setIvar ( id obj, Ivar ivar, id value );
如果实例变量的Ivar已经知道，那么调用object_getIvar会比object_getInstanceVariable函数快，相同情况下，object_setIvar也比object_setInstanceVariable快。

3.针对对象的类进行操作的函数，这类函数包含：

1
2
3
4
5
6
7
8
// 返回给定对象的类名
const char * object_getClassName ( id obj );
 
// 返回对象的类
Class object_getClass ( id obj );
 
// 设置对象的类
Class object_setClass ( id obj, Class cls );
获取类定义

Objective-C动态运行库会自动注册我们代码中定义的所有的类。我们也可以在运行时创建类定义并使用objc_addClass函数来注册它们。runtime提供了一系列函数来获取类定义相关的信息，这些函数主要包括：

1
2
3
4
5
6
7
8
9
10
11
12
13
// 获取已注册的类定义的列表
int objc_getClassList ( Class *buffer, int bufferCount );
 
// 创建并返回一个指向所有已注册类的指针列表
Class * objc_copyClassList ( unsigned int *outCount );
 
// 返回指定类的类定义
Class objc_lookUpClass ( const char *name );
Class objc_getClass ( const char *name );
Class objc_getRequiredClass ( const char *name );
 
// 返回指定类的元类
Class objc_getMetaClass ( const char *name );
objc_getClassList函数：获取已注册的类定义的列表。我们不能假设从该函数中获取的类对象是继承自NSObject体系的，所以在这些类上调用方法是，都应该先检测一下这个方法是否在这个类中实现。

下面代码演示了该函数的用法：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
int numClasses;
Class * classes = NULL;
 
numClasses = objc_getClassList(NULL, 0);
if (numClasses > 0) {
    classes = malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
 
    NSLog(@"number of classes: %d", numClasses);
 
    for (int i = 0; i < numClasses; i++) {
 
        Class cls = classes[i];
        NSLog(@"class name: %s", class_getName(cls));
    }
 
    free(classes);
}
输出结果如下：

1
2
3
4
5
6
7
8
9
10
11
12
2014-10-23 16:20:52.589 RuntimeTest[8437:188589] number of classes: 1282
2014-10-23 16:20:52.589 RuntimeTest[8437:188589] class name: DDTokenRegexp
2014-10-23 16:20:52.590 RuntimeTest[8437:188589] class name: _NSMostCommonKoreanCharsKeySet
2014-10-23 16:20:52.590 RuntimeTest[8437:188589] class name: OS_xpc_dictionary
2014-10-23 16:20:52.590 RuntimeTest[8437:188589] class name: NSFileCoordinator
2014-10-23 16:20:52.590 RuntimeTest[8437:188589] class name: NSAssertionHandler
2014-10-23 16:20:52.590 RuntimeTest[8437:188589] class name: PFUbiquityTransactionLogMigrator
2014-10-23 16:20:52.591 RuntimeTest[8437:188589] class name: NSNotification
2014-10-23 16:20:52.591 RuntimeTest[8437:188589] class name: NSKeyValueNilSetEnumerator
2014-10-23 16:20:52.591 RuntimeTest[8437:188589] class name: OS_tcp_connection_tls_session
2014-10-23 16:20:52.591 RuntimeTest[8437:188589] class name: _PFRoutines
......还有大量输出
获取类定义的方法有三个：objc_lookUpClass, objc_getClass和objc_getRequiredClass。如果类在运行时未注册，则objc_lookUpClass会返回nil，而objc_getClass会调用类处理回调，并再次确认类是否注册，如果确认未注册，再返回nil。而objc_getRequiredClass函数的操作与objc_getClass相同，只不过如果没有找到类，则会杀死进程。

objc_getMetaClass函数：如果指定的类没有注册，则该函数会调用类处理回调，并再次确认类是否注册，如果确认未注册，再返回nil。不过，每个类定义都必须有一个有效的元类定义，所以这个函数总是会返回一个元类定义，不管它是否有效。

小结

在这一章中我们介绍了Runtime运行时中与类和对象相关的数据结构，通过这些数据函数，我们可以管窥Objective-C底层面向对象实现的一些信息。另外，通过丰富的操作函数，可以灵活地对这些数据进行操作。

 
 
 


  


