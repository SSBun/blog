---
title: GCD延迟执行如何在中途取消
date: 2017-09-04 16:26:54
tags:
- GCD
categories:
- iOS
---

GCD 是我们常用的多线程技术，基于C语言给我们带来了高效的执行速度，通过 block 让代码的调用更加紧凑。但是对 GCD 中任务的管理确实十分麻烦的事情，一般情况下如果要管理多线程的任务，我们会转而使用 NSOpeartion。 如果问题复杂的话，我当然还是推荐使用 NSOpeartion， 但是如果我们只是为了延迟代码的执行，我们肯定更愿意使用 DispathAfter 这样简单的方法，这里如果你想要在某种情况下取消未执行的操作，我们该怎么办呢.

我在阅读王魏的《Swfit Tips》时看到了他所实现的一个写法，感觉很棒，这里稍加修改让它更好用一点。

```swift
import Foundation

typealias Task = (_ cancel: Bool) -> ()

@discardableResult func delay(_ time: TimeInterval, task: @escaping () -> ()) -> Task?{
    
    func dispatch_later(block: @escaping () -> ()) {
        let t = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }
    
    
    var closure: (() -> Void)? = task
    var result: Task?
    
    let delayedClosure: Task = {
        cancel in
        if let closure = closure {
            if !cancel {
                DispatchQueue.main.async(execute: closure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        if let result = result {
            result(false)
        }
    }

    return result
}

func cancel(_ task: Task?) {
    task?(true)
}

```

使用起来也是很简单，如下

```swift
let a = delay(4) {
    print("hello one !")
}
let b = delay(6) {
    print("hello two !")
}

delay(5) {
    cancel(a)
    cancel(b)
}
```

这里， 我们在5秒后，同时取消了a和b，但是a在4秒后就已经执行了，而b将会在执行前被取消。所以你只能看到打印结果 "hello one !"
