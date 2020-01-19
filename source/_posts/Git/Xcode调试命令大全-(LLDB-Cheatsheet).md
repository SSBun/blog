---
title: Xcode 调试命令大全 (LLDB Cheatsheet)
date: 2017-11-16 14:21:54
tags:
- Xcode
---

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119135128.png)

> 这是一个LLDB的常用命令表， 涵盖了平时 Debug 时用到的所有命令，在开发中能够帮助你更快的定位和调试bug

## Getting help(获取帮助)
```
(lldb) help
```
列出所有的命令和别名

```
(lldb) help po
```
获取`po`命令的帮助文档

```
(lldb) help break set
```
获取`break set`子命令的帮助文档

```
(lldb) apropos step-in
```
搜索帮助文档中包含了`step-in`的命令

## Finding Code(搜索代码)
```
(lldb) image lookup -rn UIAlertController
```
查看所有包含了`UIAlertController`并且被编译或运行的代码

```
(lldb) image lookup -rn (?i)hosturl
```
查看所有包含了`hosturl`的代码，并且不区分大小写

```
(lldb) image lookup -rn 'UIViewController\ set\w+:\]'
```
查看`UIViewController`中被实现或是重写所有的属性的`setter`方法

```
(lldb) image lookup -rn . Security
```
查看所有位于`Security`模块的代码

```
(lldb) image lookup -s mmap
```
查看标识为`mmap`的代码


## Breakpoints（断点）

```
(lldb) b viewDidLoad
```
创建一个断点，断在所有的`viewDidLoad`方法中(Swift/Objective-c都有)

```
(lldb) b setAlpha:
```
在oc的`setAlpha:`方法或是oc的`alpha`属性的`setter`方法中创建一个断点

```
(lldb) b -[CustomeViewControllerSubclass viewDidLoad]
```
在OC的`[CustomeViewControllerSubclass viewDidLoad]`中设置一个断点

```
(lldb) rbreak CustomViewControllerSubclass.viewDidLoad
```
创建一个正则断点,匹配OC和Swift中类 `CustomViewControllerSubclass` 的 `viewDidLoad` 方法,包括OC中的 `[CustomeViewControllerSubclass.viewDidLoad]` 或是 wfit 中的 `ModuleName.CustomeViewControllerSubclass.viewDidLoad() -> ()`.

```
(lldb) breakpoint delete
```
删除所有的断点
 
```
(lldb) breakpoint delete 2
```
删除id为2的断点

```
(lldb) breakpoint list
```
列出所有的断点及其id

```
(lldb) rbreak viewDid
```
创建一个正则断点匹配`.*viewDid.*`

```
(lldb) rbreak viewDid -s SwiftRadio
```
在模块`SwfitRadio`中创建一个正则断点匹配`.*viewDid.*`, 

```
(lldb) rbreak viewDid(Appear|Disappear) -s SwiftHN
```
在`Swift`模块的`viewDidAppear`和`viewDidDisappera`中创建一个断点


```
(lldb) rb "\-\[UIViewController\ set" -s UIKit
```
在`UIKit`模块中创建一个断点，断在OC中所有包含了`[UIViewController set`的方法里

```
(lldb) rb . -s SwiftHN -o
```
在`SwiftHN`模块中的所有方法中创建断点， 但是只要有一个断点被触发，就删除所有的断点

```
(lldb) rb . -f ViewController.m
```
创建一个断点，断在`ViewController.m`中的所有方法里面

## Expressions(表达式)

```
(lldb) po "hello, debugger"
```
打印`hello, debugger`

```
(lldb) expression -lobjc -O -- [UIApplication sharedApplication]
```
打印`UIApplication`的实例在OC环境下

```
(lldb) expression -lswift -O -- UIApplication.shared
```
打印`UIApplication`的实例在Swift环境下

```
(lldb) b getenv
(lldb) expression -i0 -- getenv("HOME")
```
创建一个断点在`getenv`， 然后执行`getenv`方法。程序将会断在`getenv`方法执行的地方

```
(lldb) expression -u0 -O -- [UIApplication test]
```
执行方法`[UIApplication test]`，如果此方法导致了应用崩溃了，不展开调用栈

```
(lldb) expression -p -- NSString *globalString = [NSString stringWithUTF8String: "Hello, Debugger"];
(lldb) po globalString
Hello, Debugger
```
声明一个全局的字符串变量`globalString`

```
(lldb) expression -g -O -lobjc -- [NSObject new]
```
解析`[NSObject new]`在OC中的表达


## Stepping(步进)

```
(lldb) thread return false
```
在当前代码提前返回 false

```
(lldb) thread step-in
```
执行下一行代码

```
(lldb) thread step-over
```
执行下一个方法

```
(lldb) thread step-out
```
步出当前方法

```
(lldb) thread step-inst
```
如果执行一个方法就步进，否者就进入命令集


## GDB formatting (GDB调试器格式化)

```
(lldb) p/x 128
```
输出数据的16进制格式

```
(lldb) p/d 128
```
输出数据的10进制格式

```
(lldb) p/t 128
```
输出数据的2进制格式

```
(lldb) p/a 128
```
将数据作为地址输出

```
(lldb) x/gx 0x000000010fff6c40
```
从地址`0x000000010fff6c40`中获取数据并以8字节显示

```
(lldb) x/wx 0x000000010fff6c40
```
从地址`0x000000010fff6c40`中获取数据并以4字节显示

## Memory (内存)
```
(lldb) memory read 0x000000010fff6c40
```
读取地址`0x000000010fff6c40`的内存

```
(lldb) po id $d = [NSData dataWithContentsOfFile:@"..."]
(lldb) mem read `(uintptr_t)[$d bytes]` `(uintptr_t)[$d bytes] +
(uintptr_t)[$d length]` -r -b -o /tmp/file
```
从远程文件中获取一个实例，然后写入到你电脑中的`/tmp/file`中去

## Registers & assembly (寄存器和汇编)

```
(lldb)  register read -a
```
显示系统中所有的寄存器

```
(lldb) register read rdi rsi
```
读取寄存器`rdi`和`rsi`的数据

```
(lldb) register write rsi 0x0
```
设置寄存器`rsi`的数据为 0x0

```
(lldb) disassemble
```
显示你当前的暂停方法的汇编指令

```
(lldb) disassemble -n '-[UIViewController setTitle:]'
```
解析OC中的`[UIViewController setTitle:]`方法

```
(lldb) disassemble -a 0x000000010b8d972d
```
解析一个方法，此方法包含地址`0x000000010b8d972d`

## Modules (模块)
```
(lldb) image list
```
列出当前进程中加载的所有模块的信息

```
(lldb) image list -b
```
列出当前进程中加载的所有模块的名字

```
(lldb) process load /Path/To/Module.framework/Module
```
在当前进程中加载本地模块













