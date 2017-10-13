# KVO使用与机制详解

## 简介

```
Key-value observing is a mechanism that allows objects to 
be notified of changes to specified properties of other 
objects.
```
简单来说就是可以通过`KVO`监听对象属性的变化。

## 使用
我们简单的写一个`model`类:`Person`如下：

```objc
#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *location;

@end

#import "Person.h"

@implementation Person

- (void)setName:(NSString *)name{
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}

/**
 是否自动控制监听属性的变化
 
 @param key 键值
 @return YES/NO
 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key{
    if([key isEqualToString:@"name"]){
        return NO;
    }
    return YES;
}

@end

```

写一个简单的测试例子：

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupViews];
    [self setupObservers];
}

- (void)setupViews{
    UIButton *changeNameButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    [changeNameButton setTitle:@"change name" forState:UIControlStateNormal];
    changeNameButton.backgroundColor = [UIColor redColor];
    changeNameButton.center = CGPointMake(self.view.center.x, 100);
    [changeNameButton addTarget:self action:@selector(changeName:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeNameButton];
    
    UIButton *changeAgeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    [changeAgeButton setTitle:@"change age" forState:UIControlStateNormal];
    changeAgeButton.backgroundColor = [UIColor redColor];
    changeAgeButton.center = CGPointMake(self.view.center.x, 200);;
    [changeAgeButton addTarget:self action:@selector(changeAge:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeAgeButton];
}

- (void)setupObservers{
    person = [Person new];
    person.name = @"xz";
    person.age = 20;
    person.location = @"深圳";
    NSLog(@"before %s",object_getClassName(person));
    [person addObserver:self
             forKeyPath:@"name"
                options:NSKeyValueObservingOptionNew
                context:nil];
    
    [person addObserver:self
             forKeyPath:@"age"
                options:NSKeyValueObservingOptionNew
                context:nil];
}

- (void)changeName:(id)sender{
    person.name = @"xsc";
    NSLog(@"after %s",object_getClassName(person));
}

- (void)changeAge:(id)sender{
    person.age = 22;
    NSLog(@"after %s",object_getClassName(person));
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@",change);
}
```

分别点击`change name `与`change age`输出的日志如下：

```
2017-10-12 16:22:19.606 KVOExample[27496:963593] before Person
2017-10-12 16:22:21.900 KVOExample[27496:963593] {
    kind = 1;
    new = xsc;
}
2017-10-12 16:22:21.901 KVOExample[27496:963593] after NSKVONotifying_Person
2017-10-12 16:22:23.147 KVOExample[27496:963593] {
    kind = 1;
    new = 22;
}
2017-10-12 16:22:23.148 KVOExample[27496:963593] after NSKVONotifying_Person
```

## 原理分析

```
Automatic key-value observing is implemented using a 
technique called isa-swizzling.

The isa pointer, as the name suggests, points to the 
object's class which maintains a dispatch table. This 
dispatch table essentially contains pointers to the 
methods the class implements, among other data.

When an observer is registered for an attribute of an 
object the isa pointer of the observed object is modified, 
pointing to an intermediate class rather than at the true 
class. As a result the value of the isa pointer does not 
necessarily reflect the actual class of the instance.

You should never rely on the isa pointer to determine 
class membership. Instead, you should use the class method 
to determine the class of an object instance.
```

> * 1.`isa-swizzling`的实际上是就是对象`isa`指针的替换技术。
> * 2.结合使用中的例子输出的日志`after NSKVONotifying_Person`与上述的说明我们不难分析出，当给被观察的`Person`类实例添加观察者时，默认会触发生成`NSKVONotifying_Person`的子类，子类中重写了监听的属性的`set`方法。

```
To implement manual observer notification, you invoke 
willChangeValueForKey: before changing the value, and 
didChangeValueForKey: after changing the value. The 
example in Listing 3 implements manual notifications for 
the balance property
```
> * 1.上述描述了如果需要实现手动的观察者的通知，需要在改变对应的属性的值前后分别调用`willChangeValueForKey:`,`didChangeValueForKey:`方法。结合使用中的例子，我们也得出相应的结论：`NSKVONotifying_Person`的子类中重写了`Person`属性的`set`方法，方法中分别调用了`willChangeValueForKey:`,`didChangeValueForKey:`以达到通知观察者的目的。


## 存在问题与解决

通过使用的例子不难分析出KVO存在如下几个问题：

> * 1.添加观察者与属性变化回调的代码逻辑是分开的。
> * 2.移除观察者的操作必须存在，不然会导致内存泄漏或Crash。
> * 3.属性变化监听的回调只能根据`keyPath`区分写不同的处理逻辑,代码耦合。

因此我们考虑二次封装`KVO`去解决这些问题。我们查看主流的关于这一块的封装`facebook`封装的[KVOController](https://github.com/facebook/KVOController)其实是一个不错的选择。下面我们展开分析。

## FBKVOController

### FBKVOController的使用

```objc
#import "ViewController.h"
#import "Person.h"
#import "FBKVOController.h"

@interface ViewController (){
    Person *person;
    FBKVOController *KVOController;
}

@end

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
    [self setupPerson];
       
    // 2.FB对KVO的封装
    [self setupFBKVO];
}

- (void)setupViews{
    UIButton *changeNameButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    [changeNameButton setTitle:@"change name" forState:UIControlStateNormal];
    changeNameButton.backgroundColor = [UIColor redColor];
    changeNameButton.center = CGPointMake(self.view.center.x, 100);
    [changeNameButton addTarget:self action:@selector(changeName:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeNameButton];
    
    UIButton *changeAgeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    [changeAgeButton setTitle:@"change age" forState:UIControlStateNormal];
    changeAgeButton.backgroundColor = [UIColor redColor];
    changeAgeButton.center = CGPointMake(self.view.center.x, 200);;
    [changeAgeButton addTarget:self action:@selector(changeAge:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeAgeButton];
}

- (void)setupPerson{
    person = [Person new];
    person.name = @"xz";
    person.age = 20;
    person.location = @"深圳";
    NSLog(@"before %s",object_getClassName(person));
}

- (void)setupFBKVO {
    KVOController = [FBKVOController controllerWithObserver:self];
    [KVOController observe:person
                   keyPath:@"name"
                   options:NSKeyValueObservingOptionNew
                     block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                         NSLog(@"%@",change);
                     }];
    
    [KVOController observe:person
                   keyPath:@"age"
                   options:NSKeyValueObservingOptionNew
                     block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                         NSLog(@"%@",change);
                     }];
}

- (void)changeName:(id)sender{
    person.name = @"xsc";
    NSLog(@"after %s",object_getClassName(person));
}

- (void)changeAge:(id)sender{
    person.age = 22;
    NSLog(@"after %s",object_getClassName(person));
}

```

测试结果：

```
2017-10-12 19:04:32.343 KVOExample[37615:1335210] before Person
2017-10-12 19:04:33.491 KVOExample[37615:1335210] {
    FBKVONotificationKeyPathKey = name;
    kind = 1;
    new = xsc;
}
2017-10-12 19:04:33.492 KVOExample[37615:1335210] after NSKVONotifying_Person
2017-10-12 19:04:35.053 KVOExample[37615:1335210] {
    FBKVONotificationKeyPathKey = age;
    kind = 1;
    new = 22;
}
2017-10-12 19:04:35.054 KVOExample[37615:1335210] after NSKVONotifying_Person
```

### FBKVOController 实现分析

#### FBKVOController 添加观察者

```
+ (instancetype)controllerWithObserver:(nullable id)observer
	- (instancetype)initWithObserver:(nullable id)observer
		- (instancetype)initWithObserver:(nullable id)observer retainObserved:(BOOL)retainObserved
```

```
- (instancetype)initWithObserver:(nullable id)observer retainObserved:(BOOL)retainObserved
{
  self = [super init];
  if (nil != self) {
    _observer = observer;
    NSPointerFunctionsOptions keyOptions = retainObserved ? NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality : NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality;
    _objectInfosMap = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:0];
    pthread_mutex_init(&_lock, NULL);
  }
  return self;
}
```

关于`NSMapTable`可以查看[NSHash​Table & NSMap​Table](http://nshipster.cn/nshashtable-and-nsmaptable/)。上述代码完成如下工作：
> * 1.初始化了一个全局字典，配置相应的比较策略，用于存储后续的`KVO`的实例。                      
> * 2.初始化一个全局的锁，避免多线程操作导致数据异常。


#### FBKVOController 设置观察的属性

```objc
- (void)observe:(nullable id)object
        keyPath:(NSString *)keyPath
        options:(NSKeyValueObservingOptions)options
          block:(FBKVONotificationBlock)block
```

```objc
// create info
  _FBKVOInfo *info = [[_FBKVOInfo alloc] initWithController:self keyPath:keyPath options:options block:block];
  
// observe object with info
[self _observe:object info:info];
```

> * 1.利用传入的`keyPath`,`options`初始化一个`_FBKVOInfo `实例，`_FBKVOInfo `是一个`model`类用来存在`KVO`过程中的全部信息。
> * 2.触发真正的添加观察属性的操作。

我们深入分析步骤2中的代码：

```
- (void)_observe:(id)object info:(_FBKVOInfo *)info
{
  // lock
  pthread_mutex_lock(&_lock);

  NSMutableSet *infos = [_objectInfosMap objectForKey:object];

  // check for info existence
  _FBKVOInfo *existingInfo = [infos member:info];
  if (nil != existingInfo) {
    // observation info already exists; do not observe it again

    // unlock and return
    pthread_mutex_unlock(&_lock);
    return;
  }

  // lazilly create set of infos
  if (nil == infos) {
    infos = [NSMutableSet set];
    [_objectInfosMap setObject:infos forKey:object];
  }

  // add info and oberve
  [infos addObject:info];

  // unlock prior to callout
  pthread_mutex_unlock(&_lock);

  [[_FBKVOSharedController sharedController] observe:object info:info];
}
```

> * 1.每次对全局`KVO`信息字典表的操作都需要先执行锁操作，保证安全性。
> * 2.以观察的实例作为键值，获取的集合就是观察的所有该实例的属性初始化的`_FBKVOInfo`类的集合。
> * 3.操作该集合添加新的`_FBKVOInfo`类。

#### _FBKVOSharedController 真正KVO的触发实例

##### 添加观察者

```
- (void)observe:(id)object info:(nullable _FBKVOInfo *)info
{
  if (nil == info) {
    return;
  }

  // register info
  pthread_mutex_lock(&_mutex);
  [_infos addObject:info];
  pthread_mutex_unlock(&_mutex);

  // add observer
  [object addObserver:self forKeyPath:info->_keyPath options:info->_options context:(void *)info];

  if (info->_state == _FBKVOInfoStateInitial) {
    info->_state = _FBKVOInfoStateObserving;
  } else if (info->_state == _FBKVOInfoStateNotObserving) {
    // this could happen when `NSKeyValueObservingOptionInitial` is one of the NSKeyValueObservingOptions,
    // and the observer is unregistered within the callback block.
    // at this time the object has been registered as an observer (in Foundation KVO),
    // so we can safely unobserve it.
    [object removeObserver:self forKeyPath:info->_keyPath context:(void *)info];
  }
}
```
> * 观察的实例将`[_FBKVOSharedController sharedController]`实例添加到观察者中，全局的上下文传入初始化好的`KVO`的全局信息`info`，这样在触发回调时可以区分处理。


##### 处理KVO回调

```objc
- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context
{
  NSAssert(context, @"missing context keyPath:%@ object:%@ change:%@", keyPath, object, change);

  _FBKVOInfo *info;

  {
    // lookup context in registered infos, taking out a strong reference only if it exists
    pthread_mutex_lock(&_mutex);
    info = [_infos member:(__bridge id)context];
    pthread_mutex_unlock(&_mutex);
  }

  if (nil != info) {

    // take strong reference to controller
    FBKVOController *controller = info->_controller;
    if (nil != controller) {

      // take strong reference to observer
      id observer = controller.observer;
      if (nil != observer) {

        // dispatch custom block or action, fall back to default action
        if (info->_block) {
          NSDictionary<NSKeyValueChangeKey, id> *changeWithKeyPath = change;
          // add the keyPath to the change dictionary for clarity when mulitple keyPaths are being observed
          if (keyPath) {
            NSMutableDictionary<NSString *, id> *mChange = [NSMutableDictionary dictionaryWithObject:keyPath forKey:FBKVONotificationKeyPathKey];
            [mChange addEntriesFromDictionary:change];
            changeWithKeyPath = [mChange copy];
          }
          info->_block(observer, object, changeWithKeyPath);
        } else if (info->_action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [observer performSelector:info->_action withObject:change withObject:object];
#pragma clang diagnostic pop
        } else {
          [observer observeValueForKeyPath:keyPath ofObject:object change:change context:info->_context];
        }
      }
    }
  }
}
```
> * 1.根据回到的context获取`KVO`的全部信息，然后选择`block`，'action',原生处理三种不同的方式分发处理。

##### 移除观察者

回到`FBKVOController`类，聚焦到`dealloc`函数中，该函数是在对象被释放时触发。

```objc
- (void)dealloc
{
  [self unobserveAll];
  pthread_mutex_destroy(&_lock);
}
```

查看调用栈信息最终的触发函数如下:

```objc
- (void)_unobserveAll
{
  // lock
  pthread_mutex_lock(&_lock);

  NSMapTable *objectInfoMaps = [_objectInfosMap copy];

  // clear table and map
  [_objectInfosMap removeAllObjects];

  // unlock
  pthread_mutex_unlock(&_lock);

  _FBKVOSharedController *shareController = [_FBKVOSharedController sharedController];

  for (id object in objectInfoMaps) {
    // unobserve each registered object and infos
    NSSet *infos = [objectInfoMaps objectForKey:object];
    [shareController unobserve:object infos:infos];
  }
}
```
> * 1.清理掉全局存储的KVO的信息集合。
> * 2.`shareController`中也需要清理存储的KVO的信息，同时移除观察者。参考如下代码段：

```
- (void)unobserve:(id)object infos:(nullable NSSet<_FBKVOInfo *> *)infos
{
  if (0 == infos.count) {
    return;
  }

  // unregister info
  pthread_mutex_lock(&_mutex);
  for (_FBKVOInfo *info in infos) {
    [_infos removeObject:info];
  }
  pthread_mutex_unlock(&_mutex);

  // remove observer
  for (_FBKVOInfo *info in infos) {
    if (info->_state == _FBKVOInfoStateObserving) {
      [object removeObserver:self forKeyPath:info->_keyPath context:(void *)info];
    }
    info->_state = _FBKVOInfoStateNotObserving;
  }
}
```

**参考文章:**

[如何优雅地使用 KVO](https://draveness.me/kvocontroller.html)