---
title: 在 Swift5.5 中 Double 和 CGFloat 的自动转换
date: 2021-06-21 13:37:07
tags:
- swift
marks:
- TRANSLATION:gray
- language features:blue
---

> 此为译文，原文连接: [Automatic conversions between Double and CGFloat values in Swift 5.5](https://www.swiftbysundell.com/tips/double-cgfloat-auto-conversions/)

*Swift5.5 新特性:* **编译器现在能够在 CGFloat 和 Double 之间自动进行转换.**

尽管在 64 位系统中，CGFloat 和 Double 在底层是相等的类型，但是在 Swift5.5 以前因为 Swift 的强类型系统，CGFloat 和 Double 之间必须手动强转才能使用。CGFloat 和 Double 在 Swift 的类型系统当中也确实是完全不同的两个类型。

然而，当我们使用字面量的时候，编译器总是能够根据上下文自动选择合适的变量类型。例如，在下面的 SwiftUI 视图中，我们设置了 `scaleEffect` 和 `opacity`  两个修饰器，它们一个接收 CGFloat 类型的值， 一个接收 Double 类型的值，我们直接使用字面量，并没有指定数据类型。

```Swift
struct DecorationImage: View {
    var name: String

    var body: some View {
        Image(name)
            .scaleEffect(0.5) // This is a CGFloat
            .opacity(0.8) // This is a Double
    }
}
```
如果我们替换字面量为两个属性，然后我们强制设置`scale` 为 CGFloat 类型，如果不强制设置的话，根据上下文，编译器会把 `scale` 自动解释为 Double 类型。当我们把这个属性赋值给 `scaleEffect`时，编译器会报错。

```Swift
struct DecorationImage: View {
    var name: String
    var scale: CGFloat = 0.5
    var opacity: CGFloat = 0.8

    var body: some View {
        Image(name)
            .scaleEffect(scale)
            .opacity(opacity)
    }
}
```

但是在 Swift5.5 中，就不在有这个的问题了，我们现在可以随意的把一个 Double 类型的值传到一个接收 CGFloat 参数的函数中去。反之，我们也可以自由的设置我们的属性是 CGFloat 或是 Double， 亦或者不再指定它们的类型，让编译器把它们的类型默认为 Double。

```Swift
struct DecorationImage: View {
    var name: String
    var scale = 0.5
    var opacity = 0.8

    var body: some View {
        Image(name)
            .scaleEffect(scale)
            .opacity(opacity)
    }
}
```
这个新特性不仅仅只适用于系统 API，任何使用到 CGFloat 和 Double 类型的代码都可以使用这个特性，虽然是一个很小的改动，但是非常的好用。