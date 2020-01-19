---
title: Objective-C 宏定义
date: 2016-10-18 14:55:54
tags:
- Macro
categories:
- iOS
---

喜欢读一些开源项目源码的人，总是会发现，大神的代码中总是有那么一些简短而高效的宏定义，点击进去一看，发现晦涩难懂，别说学习了，有时候理解都是一种困难，但是宏定义本身并没有那么难，但是写出一个好的宏当然还是需要丰富的经验和技术，接下来就说一说宏定义，看懂大神的宏是第一步，偶尔写一个也是装逼的好办法～

## 定义

宏定义分为两种：一种是对象宏（object-like macro）另一种就是函数宏(function-like macro)
根据名字也可以理解到，**对象宏**就是用来定义一个量，通过这个宏可以拿到这个变量，比如我们定义一个π值: `#define PI 3.1415926` 在这里如果用到π值时，就不需要再写出一个浮点数了，而直接使用`PI`就相当写入了这个常量浮点数，其本质的意义在于把代码中的 `PI` 在编译阶段替换为真正的常量，一般用来定义一些常用的常量，比如屏幕的宽高、系统版本号等。但是需要注意的是，但你定义一个表达式为宏的时候，需要透过宏的表面，看到器编译的本质，例如

```objc
#define MARGIN  10 + 20
```

但你用它来计算一个宽度时，如果用到了 `MARGIN * 2`，结果将会非你所愿，你得到的会是一个 50 而并非 60，展开表达式就可以看到

```objc
MARGIN * 2 // 展开可以得到
//  10 + 20 * 2  = 50
```

我们需要考虑到它的运算优先级，解决的方式很简单，再它的外层加上一个小括号

```objc
#define MARGIN (10 + 20)
// MARGIN * 2
// (10 + 20) * 2 = 60
```

**函数宏**的作用就类似于一个函数一样，它可以传递参数，通过参数进行一系列的操作，比如我们常用的计算两个数的最大值，我们可以这样来定义

```objc
#define MAX(A,B)  A > B ? A : B
```

这样写看起来是没有问题的，进行简单的比较 `MAX(1,2)` 发现也是没有什么问题,但是当有人使用你的宏进行更加复杂的计算时就回出现新的问题，比如进行三个数值的计较时，可能会这样写

```objc
int a = 3;
int b = 2;
int c = 1;
MAX(a, b > c ? b : c)  //
= 2
```

结果肯定也不是你想要的，最大值很明显是 3，但是计算的结果确实 2，这其中发生了什么导致计算出错，我们可以展开宏来一探究竟，下面是宏的展开

```objc
MAX(a,b > c ? b : c);
//a > b > c ? b : c ? a : b > c ? b : c
//(a > (b > c ? b : c) ? a : b) > c ? b : c // 这是运算的优先级
// 带入值可以看出
//( 3 > (2 > 1 ?  2 : 1 ) ? 3 : 2) > 1 ? 2 : 1
// (3 > 2 ? 3 : 2) > 1 ? 2 : 1
// 3 > 1 ? 2 : 1
```

想必大家都看出来了问题所在，还是由于优先级的问题，所以在此谨记，反正多写两个括号也不会累着，不管会不会出现问题，** *写上小括号终究是保险一些~* **
可是总有写奇葩的写法会出现，而且看开起来还很有道理的样子～

```objc
c = MAX(a++,b); //  **我直接展开给你看就得了**
// c = a++ > b ? a++ : b
// c = 3++ > 2 ? 3++ : 2
// c = 4
// a = 5
```

不管这样写的那个人是有多欠揍，但是毕竟看起来是没有任何问题的，所有我们要处理这样的情况，但是使用我们普通的小括号已经无法解决，我们需要使用赋值扩展 `({...})` 相信有朋友已经认出来了这种用法了，我们可以使用这样的方法来计算出一个对象，而不用浪费变量名，可以形成小范围的作用域来计算特殊的值

```objc
int a = ({
  int b = 10;
  int c = 20;
  b + c;
})
// a = 30;
int b; // 继续使用b和c当变量名也没有问题
int c;
```

再回到现在这个问题上，我们该如何改装这个宏来让其适应这个坑爹的写法呢

```objc
#define MAX(A,B) ({__typeof(A) __a = (A);__typeof(B) __b = (B); __a > __b ? __a : __b; })
```

`__typeof()`就是转换为相同类型的变量值，就完美的解决了这个问题，但是还有一个不怎么会发生的意外，通过上面也可以知道，我们生成了新的变量 `__a, __b`,如何有人使用了 `__a,__b`，就会应为变量名重复而编译错误，如果有人这样用了，你可以拿起你的键盘砸他一脸，原因当然不是 `__a` 使你的宏错误了，而是 `__a` 到底是什么意思，变量名的重要性不言而喻，除非你和看代码的人有仇，否则请使用有意义的变量名,接下来让我们看一看官方的MAX是如何实现的

```objc
#define __NSX_PASTE__(A,B) A##B

#if !defined(MAX)
    #define __NSMAX_IMPL__(A,B,L) ({ __typeof__(A) __NSX_PASTE__(__a,L) = (A); __typeof__(B) __NSX_PASTE__(__b,L) = (B); (__NSX_PASTE__(__a,L) < __NSX_PASTE__(__b,L)) ? __NSX_PASTE__(__b,L) : __NSX_PASTE__(__a,L); })
    #define MAX(A,B) __NSMAX_IMPL__(A,B,__COUNTER__)
#endif
```

这是 `Function` 框架中的MAX定义，我么来一步一步的解析它，首先看见的是

```objc
#define __NSX_PASTE__(A,B) A##B
// 将A和B连接到一块
```

它的作用是将 `A` 和 `B` 连接到一块,用来生成一个的字符串，比如 `A##12` 就成了 `A12`
接下来我们看到了一个有三个参数的宏定义`__NSMAX_IMPL__(A,B,__COUNTER__)`

```objc
#if !defined(MAX)
    #define __NSMAX_IMPL__(A,B,L) ({ __typeof__(A) __NSX_PASTE__(__a,L) = (A); __typeof__(B) __NSX_PASTE__(__b,L) = (B); (__NSX_PASTE__(__a,L) < __NSX_PASTE__(__b,L)) ? __NSX_PASTE__(__b,L) : __NSX_PASTE__(__a,L); })
    #define MAX(A,B) __NSMAX_IMPL__(A,B,__COUNTER__)
#endif
```

我们先来解释 `__COUNTER__` 是什么，`__COUNTER__` 是一个预编译宏，它将会在每次编译时加1，这样的话可以保证 `__NSX_PASTE__(__b,__CONNTER__)` 生成的变量名不易重复，但是这样还是有那么点危险，就是你要是起变量名叫 `__a20`，那就真的真的没有办法了~

###可变参数宏
说起可变参数，我们用的最多的一个方法 `NSLog(...)` 就是可变参数了，可变参数意味着参数的个数是不定的，而 `NSLog` 作为我们调试时一个重要的工具实在时太废物了，只能打印对应的时间和参数信息，而文件名，行数，方法名等重要的信息都没有给出，今天我们就借此来实现一个超级版 `NSLog` 宏～～～

```objc
#define NSLog(format, ...)  do { fprintf(stderr, "<%s : %d> %s\n", \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __func__); \
(NSLog)((format), ##__VA_ARGS__); \
fprintf(stderr, "-------\n"); \ } while (0)
```

首先看这个宏的定义 `NSLog(format,...)` 发现它有 `...`,这就是可变参数，而 `__VA__ARGS__` 就是除了 `format` 外剩下的所有参数，接下来我们发现使用了一个 `do{}while(0)` 循环，说明这个循环只执行一便就回停止，感觉废话啊，我们的目的就是只执行一遍啊，但这样写又是为了进行`防御式编程`，如果有人这样写的话

```objc
if (100 > 99)
  NSLog(@"%@",@"Fuck");
```

就会出现无论如何都会执行后两个打印，出现的问题想必大家也都知道，那我们直接使用 `{}` 给扩起来不就行了，实际操作后确实是解决了这个问题，但是再扩展一下，当我们使用了 `if{} else if{}` 时又会出现新的问题

```objc
if (100 > 99)
  NSLog(@"%@",@"Fuck");
else {
}
// 展开后可得
if (100 > 99)
{ fprintf(stderr, "<%s : %d> %s\n",
  [[[NSString stringWithUTF8String:__FILE__] lastPathComponent]  UTF8String], __LINE__, __func__);
  (NSLog)((format), ##__VA_ARGS__);
  fprintf(stderr, "-------\n");};
else {
}
```

编译错误，大家也发现了 `NSLog` 后面会跟上`;`，如果我么直接使用了`{}`后，会在编译时在外面加上`;`，导致编译错误，而使用了 `do{} while(0)` 循环后就不会出现这个问题了

```objc
if (100 > 99)
 do { fprintf(stderr, "<%s : %d> %s\n",
  [[[NSString stringWithUTF8String:__FILE__] lastPathComponent]  UTF8String], __LINE__, __func__);
  (NSLog)((format), ##__VA_ARGS__);
  fprintf(stderr, "-------\n");} while(0);
else {
}
```

到此位置问题解决的差不多了，看一下内部的结构,`__FILE__` 是编译的文件路径,`__LINE__` 是行数，`__func__` 是编译的方法名,下面我们又看见了

```objc
(NSLog)((format), ##__VA_ARGS__);
```

`##`上面已经看见过了，在这里的作用差不多，也是连接的意思，`__VA_ARGS__` 是剩下的所有参数，使用`##`连接起来后就时 `NSLog(format,__VA_ARGS__)` 了，这就是 `NSLog` 的方法了，但是不知道有没有人发现一个细节，如果 `__VA_ARGS__` 为空的话，那岂不是成了 `NSLog(format,)` 这样肯定会编译报错的，但是苹果的大神们早就想到了解决的方法，如果 `__VA_ARGS__` 为空的话，在这里`##`将会吞掉前面的`,`，这样一来就不会出问题了。然后我们就可以使用这个强大的 `NSLog()` 了。

**接下说一下多参数函数的使用**

```objc
- (void)say:(NSString *)code,... {    
    va_list args;
    va_start(args, code);
    NSLog(@"%@",code);
    while (YES) {
        NSString *string = va_arg(args, NSString *);
        if (!string) {
            break;
        }
        NSLog(@"%@",string);
    }
    va_end(args);
}
```

我们可以要先定义一个 `va_list args` 来定义多参数变量 `args`,然后通过 `va_start(args, code)` 来开始取值,`code` 是第一个值,`va_arg(args, NSString *)` 来定义取出的值类型，取值方式有点像生成器，取完之后调用 `va_end(args)` 来关闭。这就是整个过程，平时很少使用这样的方法，如果你有什么好的**实用方法**请评论指教～～～
