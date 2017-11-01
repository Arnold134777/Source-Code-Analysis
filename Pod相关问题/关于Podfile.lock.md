# 关于Podfile.lock

最近开发遇到问题很奇怪，一个模块的代码静态库的方式引入会造成部分功能无法使用的bug,而源码引入就不会。尝试很多次，还是如此。思考整个打包静态库的过程，每次都会先执行`rm -rf Podfile.lock`,尝试更改命令屏蔽掉这个逻辑后，发现打出的包功能可以正常使用了。问题得以解决，但是不得不让我对`Podfile.lock`产生疑问，它的作用是什么？为什么删除会影响？下面展开分析。

## 什么是Podfile.lock
我们老看官方给出的解释：

```
This file is generated after the first run of pod install, 
and tracks the version of each Pod that was installed. 
```
> * `Podfile.lock`是用来进行版本控制的，这样保证多人协作开发同一个项目时，项目依赖的第三方库的版本是一致的。[官方也举例子](https://guides.cocoapods.org/using/using-cocoapods.html)说明了，可以查看一下。
> * 由上述我们得出在我们利用`git`等版本控制工具时，`Podfile.lock`也同样需要提交上去。

## 什么情况下会更新Podfile.lock
> * 主动修改`Podfile`中某个第三方库的版本，或者添加删除了某个第三方库，然后重新执行了`pod install`。
> * 主动执行`pod update`这样会更新所有的依赖库，类似第一次执行`pod install`。

## Pod Install 与 Pod Update的区别
我们直接来看项目中两处第三方库的依赖：

```
loading.dependency 'SVProgressHUD'
toast.dependency 'Toast'
```

分别执行`pod install`与`pod update`生成的`Podfile.lock`如下：

```
- SVProgressHUD (2.0.3)
- Toast (3.0)
```

```
- SVProgressHUD (2.1.2)
- Toast (3.1.0)
```

> * `pod install`只能添加删除库，不能更改现有库依赖的版本号(如果手动更改`Podfile`指定特定的版本或版本区间例外)；`pod update`则同时会更新依赖的库的版本。

## 涉及的相关的问题
#### 1.编译项目中常会出现如下错误

```
PhaseScriptExecution Check Pods Manifest.lock...
...
error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation
```

> * `Manifest.lock`是`Podfile.lock`的备份，当执行`pod install`或者`pod update`成功时都会生成一份`Podfile.lock`的拷贝`Manifest.lock`，每次编译时会检测二者是否一致，不一致就需要重新执行`pod install`。

检测的代码在`Build Phases`->`Check Pods Manifest.lock`中可以查看到如下:

```shell
diff "${PODS_ROOT}/../Podfile.lock" "${PODS_ROOT}/Manifest.lock" > /dev/null
if [ $? != 0 ] ; then
    # print error to STDERR
    echo "error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation." >&2
    exit 1
fi
```

#### 2.安装`cocoapods`的时候,执行`pod setup`

```
Setting up CocoaPods master repo  time out
```

`RubyGems`镜像源失效，执行如下的命令切换镜像源：

```
$ gem sources -r https://rubygems.org/ 
$ gem sources -a https://gems.ruby-china.org/ 
$ gem sources -l 
```


### 参考
- http://www.samirchen.com/about-podfile-lock/
- http://blog.startry.com/2015/10/28/Somthing-about-Podfile-lock/