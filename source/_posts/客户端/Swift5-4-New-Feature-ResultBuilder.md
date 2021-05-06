---
title: Swift5.4 New Feature ResultBuilder
date: 2021-05-06 15:10:47
tags:
- Swift
- Swift Updates
---

Recently, the Apple team released the new Swift version 5.4. In this update, Swift imports some new syntax. One of them most important I think of is `ResultBuilder`. Actually, this `ResultBuilder` has already can be used in previous Swift versions. But it's name is `_functionBuilder`. In SwiftUI, Apple often uses it as the Container View's constructor's property. The `body` property in SwiftUI is also declared with it. 

But as you think of, the `_functionBuilder` has a underline prefix, this means Apple doesn't want to us using this syntax. Today, the finished version of the `_functionBuilder` is coming. It provides more functions than _functionBuilder. 

## What's the problem resolved by ResultBuilder ?

Let's use the Apple official demo:

```Swift
protocol Drawable {
    func draw() -> String
}
struct Line: Drawable {
    var elements: [Drawable]
    func draw() -> String {
        return elements.map { $0.draw() }.joined(separator: "")
    }
}
struct Text: Drawable {
    var content: String
    init(_ content: String) { self.content = content }
    func draw() -> String { return content }
}
struct Space: Drawable {
    func draw() -> String { return " " }
}
struct Stars: Drawable {
    var length: Int
    func draw() -> String { return String(repeating: "*", count: length) }
}
```

The above demo's function is just generates different strings. We can use the struct `Line` to merge serval `Drawable` instances to one and then use the function `draw()` to generate a string.
Normally we use it like these:

```Swift
let line = Line(elements: [
    Text("--"),
    Space(),
    Stars(length: 3),
    Space(),
    Text("--")
])

print(line.draw()) //-- *** --
```

`ResultBuilder` provides a very clean way to do this. You can implement above function through following code:

```Swift
@DrawingBuilder
func drawing() -> Drawable {
    Text("--")
    Space()
    Stars(length: 3)
    Space()
    Text("--")
}
print(drawing().draw())
```

As you can see. In this function, we don't declare any parameters and don't use a return in its body. Just like declare UI trees in SwiftUI. The attribute `@DrawingBuilder` is the key to do this.

```Swift
@resultBuilder
struct DrawingBuilder {
    static func buildBlock(_ components: Drawable...) -> Drawable {
        Line(elements: components)
    }
}
```

We declare a struct `DrawingBuilder` with the attribute `@resultBuilder`. The only requisite function resultBuilder needs is `buildBlock`. 

In the method `drawing's` body, we can only instance types conformed `Drawable` protocol it they don't have `let` or `var`. If you write a `return` keyword, this function will become a normal method. the `@DrawingBuilder` will be ignored.

We invoke the method `drawing` will invoke the `buildBlock` method like this: 

```Swift
DrawingBuilder.buildBlock(Text("--"), Space(), Stars(length: 3), Space(), Text("--")) // = drawing()
```

## Transform Component and Result

`resultBuilder` declares many functions to implement different function. Following two methods can help us to transform values during runtime.

```Swift
static func buildExpression(_ expression: Drawable) -> Drawable {
    expression
}
static func buildFinalResult(_ component: Drawable) -> Drawable {
    component
}    
```

When the function `buildBlock` is invoked, all the components will invoke the method `buildExpression` to transform to a new component. In this, you can modify or replace the component or do nothing. Like the `map` function of a sequence.

When the function `buildBlock` return the **result**. resultBuilder will invoke the function `buildFinalResult` and pass the **result**. Finally, the `buildFinalResult`'s return value is returned as the final result.

## IF / IF ELSE / SWITCH

Sometimes we need some conditionals during generating result. In normal function, we can write condition expressions to do this. But in `resultBuilder`, we can only use `if`, `if else` and `switch` expressions by implement three functions.

```Swift
static func buildOptional(_ component: Drawable?) -> Drawable {
   component ?? Text("")
}
static func buildEither(first component: Drawable) -> Drawable {
    component
}    
static func buildEither(second component: Drawable) -> Drawable {
    component
}
```

The function `buildOptions` is invoked by single `if` expression. The functions `buildEither(first:)` and `buildEither(second:)` are invoked by `if else` expression. If's body invoke the first method, the else's body invoke the second one.

Implementing the two `buildEither` method, you can write switch expression directly. 

```Swift
@DrawingBuilder
func drawing() -> Drawable {
    let condition = 2
    if condition % 2 == 0 {
        Stars(length: 10)
    }
    if condition % 2 != 0 {

    } else {

    }
    Space()
    Stars(length: 3)   
}
```

> You can’t use break, continue, defer, guard, or return statements, while statements, or do-catch statements in the code that a result builder transforms

## LOOP

```Swift
static func buildArray(_ components: [Drawable]) -> Drawable {
    Line(elements: components)
}

@DrawingBuilder
func drawing() -> Drawable {   
    for i in 0...3 {
        Stars(length: i)
        Stars(length: i * 10)
    }
}
```

In the function `drawing`, the loop executes four times. so the components of the function `buildArray` has four elements. Every element is generated by the function `buildBlock` with the loop's body `buildBlock(Stars(length: i), Stars(length: i * 10))`.


## buildLimitedAvailability

It's used in the compiler available expressions (`#available`). If we use a available condition expression in a result builder. The result value might contains the type info about the unavailable type. This could cause your program to crash. But it's rare scene, I don't want to deep it. You can read [the apple document](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID633) to get more detail about it.


## 