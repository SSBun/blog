---
title: Swift4 中参数类型为元组的单参数函数与多参数函数的类型问题
date: 2018-01-19 19:03:54
tags:
- Swift
categories:
- iOS
---


这是一个有意思的问题，当时我是在处理函数的柯里化，突然发现了 Swift 的柯里化函数库 `Curry` 中的函数参数与我平时写的时候有些许不一样，然后我就分析了一下它们的区别，以及为什么要这样做，其中还有一些问题，我只是猜测了 Swift 中的行为，但是其背后的具体原因我暂时还不知道，或许以后会了解，不过如果有哪位朋友知道的话，可以留言给我，在此谢过。


虽然是在处理函数的柯里化是发现的问题，但是这个问题和函数柯里化并没有什么太大的关系，所以在此就不多说函数柯里化的问题了，如果有朋友有兴趣的话可以去看看函数式编程。

今天的问题主要和泛型有关，我在此认为大家对 Swift 及 Swif 的泛型都有了一定的了解，也不再赘述相关的知识，接下来我们看一下我遇到的问题

### (A, B) -> C  与 ((A, B)) -> C 有区别吗

首先，我们肯定，它们一定是有区别的，比如

```Swift
func add(_ l: Int, _ r: Int) -> Int {
    return l + r
}
// (A, B) -> C

func add(_ value: (Int, Int)) -> Int {
    return value.0 - value.1
}
// ((A, B)) -> C

func addS(_ value: (Int, Int)) -> Int {
    return value.0 - value.1
}
// ((A, B)) -> C
```

我们可以看出第一个是有两个参数的函数，第二个和第三个是只有一个参数的函数，实际上第二个 `add` 和 `addS` 是一模一样的，我之所以写了两个 `add` 是为了让大家知道，Swfit 的类型系统也是认为第一个  `add` 和第二个 `add` 是不同的，负责它也不会允许我重载 `add` 函数。而 `addS` 只是为了一会我进行处理的时候，能通过名字分出到底是哪个函数。

到现在为止我想大家都没有疑问，接下就是见证问题的时刻了，我写了一个柯里化函数，它接受一个`多参数函数`类型的参数并返回一个`单参数函数`类型的结果。不用想那么多，你一看就知道了

```Swift
func curry<A, B, C>(_ function: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { (a: A) -> (B) -> C in { (b: B) -> C in function(a, b)}}
}
```

我们只关注 `curry` 的方法定义，我们很容易就看出这个函数的参数是 `function`，而这个 `function` 的类型就是 `(A, B) -> C`，那我们就知道这个 `curry` 函数接受一个函数作为参数，而这个函数接受两个参数并返回一个结果，显然我的思路应该没有问题。

但是，为什么 `Curry`的作者并没有这样写，他为了修复一个bug而做了一点点修改，文末我们会做分析，我们看一下作者是如何写的

```Swift
func curry<A, B, C>(_ function: @escaping ((A, B)) -> C) -> (A) -> (B) -> C {
    return { (a: A) -> (B) -> C in { (b: B) -> C in function((a, b))}}
}
```

看出来区别没有，`curry` 的参数 `function` 的类型由 `(A, B) -> C` 变为了 `((A, B)) -> C`, 他们有什么区别，我认为第一个函数是接受两个参数的，而第二个函数是只有一个参数的，而这个参数的类型是元组。 那问题就来了，如果你只是接受单参数的函数，又如何去柯里化一个多参数函数呢，类型都对不上。我就果断尝试了一下

```Swift
func add(_ l: Int, _ r: Int) -> Int {
    return l + r
}
// (A, B) -> C

func addS(_ value: (Int, Int)) -> Int {
    return value.0 - value.1
}
// ((A, B)) -> C

func curry<A, B, C>(_ function: @escaping ((A, B)) -> C) -> (A) -> (B) -> C {
    return { (a: A) -> (B) -> C in { (b: B) -> C in function((a, b))}}
}

curry(addS)
curry(add)
```
这里，如果看 `curry(addS)` 获取还说的过去是吧, 毕竟类型是对上的。可是往下看，你就会发现 `curry(add)` 怎么能对的上呢，一个类型是 `(A, B) -> C`， 而另一个要的是 `((A, B)) -> C` 啊，可是编译器还就是不警告，不报错，一切完美的很。仿佛 `(A, B) -> C` 与 `((A, B)) -> C` 完美的契合了。

当时我的猜想就是在 Swift 当中 `add` 和 `addS` 的类型是相同的， 可是我们明明看的见 `add` 和 `addS` 他们之间巨大的差异啊，连参数个数都不一样的函数，他们的类型怎么会是相同的呢，但我们看见，我们分析的是如此，那 Swift 的编译器是怎么看的呢？我们打印一下不就知道了吗？

```Swift
print(type(of: add))        
//(Int, Int) -> Int
print(type(of: addS))     
//(Int, Int) -> Int
```

我凸(艹皿艹 )， 为何是这样？ 为何 `addS`的类型是 `(Int, Int) -> Int`, 如果光看这个类型的话，你怎么想也是说这个函数有两个 `Int` 型的参数而不会想这个函数是只有一个 `(Int, Int)` 元组型的参数吧。
难道个案，既然如此我们就再试一个

```Swift
func addThree(_ a: Int, _ b: Int, _ c: Int) -> Int {
    return 0
}

func addThreeS(_ a: (Int, Int, Int)) -> Int {
    return 0
}

print(type(of: addThree))   //(Int, Int, Int) -> Int
print(type(of: addThreeS))  //(Int, Int, Int) -> Int

```

瞎了我的眼了，看来 Swift 编译器是认定了他们是一个类型了
可是。。。这也不对啊
从上文的 `curry(add)` 可以看出，你显然是把 `add` 看作了 `((A,B)) -> C`, 而这里倒好，把所有的都看成了 `(A, B) -> C`, 这里我们就大胆的假设一下，在函数的类型表达里 `(A, B) -> C` 和 `((A, B)) -> C` 是等价的，甚至可以扩展到任意多参数的 `(A, B, ... G) -> Z` 至 `((A, B, ... G)) -> Z`当中去，那事实是什么样的嘞？

```Swift
if type(of: addThree) == (((Int, Int, Int)) -> Int).self {
    print("good")
}
//  good
if type(of: addThree) == ((Int, Int, Int) -> Int).self {
    print("good")
}
// good

if (((Int, Int, Int)) -> Int).self == ((Int, Int, Int) -> Int).self {
    print("good")
}
// good

```

果然，他们之间是没有区别的，至少在类型上是这个样子。
可是不管怎么说，这看起来都不是很科学，我们再来看看 `curry` 的例子。
现在我们认为 `(A, B) -> C` 和 `((A, B)) -> C`是一样的, 而这里的 `curry` 函数式我自己写的，他要的类型是 `(A, B) -> C`

```Swift
func add(_ l: Int, _ r: Int) -> Int {
    return l + r
}
// (A, B) -> C

func addS(_ value: (Int, Int)) -> Int {
    return value.0 - value.1
}
// ((A, B)) -> C

// 注意他的类型是 (A, B) -> C
func curry<A, B, C>(_ function: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { (a: A) -> (B) -> C in { (b: B) -> C in function(a, b)}}
}

// 注意他的类型是 ((A, B)) -> C
func curryS<A, B, C>(_ function: @escaping ((A, B)) -> C) -> (A) -> (B) -> C {
    return { (a: A) -> (B) -> C in { (b: B) -> C in function((a, b))}}
}

curry(add) // OK
curry(addS) // Error !!!!

curryS(add) // OK
curryS(addS) // OK
```

我去你大爷的，讲不讲道理，你一个 `curryS` 是 `((A, B)) -> C`类型的，但既可以接受 `((A, B)) -> C` 也可以接受 `(A, B) -> C` 的，这都不重要了，经过我们的验证，我们知道了 `(A, B) -> C` 似乎和 `((A, B)) -> C`很一样。

但是为什么我的 `curry` 参数类型为 `(A, B) -> C`的函数， 就不能处理你那个 `addS` 呢，虽然这样看起来很有道理， 但是毕竟是 `curryS` 先不讲道理的。

**我们的分析结果就是 `((A, B)) -> C` 既可以对接 `((A, B)) -> C` 也可以对接 `(A, B) -> C`。
而我们可怜的 `(A, B) -> C` 却只能对接与之相对应的 `(A, B) -> C`。**

**这简直没有天理啊！**


### 泛型遇到的问题

虽然我们的结论得出来了，但是我们却不理解为何是这样的，我很惆怅啊！
但是回到我最初想要解决的问题，我是要写一个柯里化函数的啊！

那我最开始写的那个参数类型为 `(A, B) -> C` 的 `curry` 函数并没有问题啊，它是可以处理两个参数的函数的，虽然说你这个 `curryS` 比较牛逼，人家总共就一个参数，无非就是参数为元组而已，你竟然也能把别人给柯里化了, 但是我不追求那么牛逼行吧，我用 `curry` 应该也能实现正常的功能。 
但是这里又要引入另一个函数了，我们不想还要看一眼这个函数是不是只有一个参数，如果只有一个参数就不能柯里化了，我们加入一个函数，这个函数会处理只有一个参数的函数，并把它原样返回。

```Swift
func curry<A, B>(_ function: @escaping (A) -> B) -> (A) -> B {
    return { (a: A) -> B in function(a) }
    // return function
}
```

上面写的看起来复杂了一点，也只是为了和后面更多的 `curry` 函数保持一致而已，你完全可以直接返回 `function`。

可是一旦加上这个函数，问题就来了，你尝试使用我们写的接受两个参数的 `curry` 函数去处理 `add` 函数的时候，发生了错误，报错为： `Ambiguous use of 'curry'`。
经历了以上的过程以后，我感觉 Swift 编译器挺牛B的啊，怎么到了这就分不出来用哪个了呢？
它肯定是不知道该用一个参数版的 `curry` 还是两个参数版的 `curry`，你说它是不是脑残，我明明传入的是一个两个参数的函数，你当然要用两个参数版本的 `curry` 来处理喽！！！

可是别忘了，Swift可是能把 `(A, B) -> C` 看成 `((A, B)) -> C`的哦，那这里它就纠结了，我是该把函数看成 `(A, B) -> C` 来当做一个2个参数的函数来处理呢，还是把它看成 `((A, B)) -> C` 来当做只有一个参数的函数呢？ 

既然如此，那我们就妥协吧，使用 `curryS` 版本的 `curry` 函数。 从这里开始我们所说的 `curry` 就是那个参数类型为 `((A, B)) -> C` 的版本。

使用新的 `curry` 处理 `add` 函数时，发现一点问题都没有了，简直6的不能行啊。我们看一下 Swift 是怎么个想法。

在这里如果 Swfit 把 `add` 看做了 `(A, B) -> C` 那就没有问题喽，函数有两个参数，那就交给参数类型为 `((A, B)) -> C` 的 `curry` 处理就好了，我们知道它是能做的到的（无奈🤷‍♀️）。

而如果 Swift 把 `add` 看做为 `((A, B)) -> C` 类型的函数，虽然第一个 `curry` 和第二个 `curry` 都是接受一个参数，但是根据泛型的处理逻辑，显然类型为 `((A, B)) -> C` 的 `curry` 比类型为 `(A) -> B` 的 `curry` 所描述的范围更严格，那只能还是使用第二个 `curry` 喽。

**好了，到此为止，所有的问题都解决了。留下的最后的问题就是上面提到过的，Swift 为什么要这么干，为何呢？**




