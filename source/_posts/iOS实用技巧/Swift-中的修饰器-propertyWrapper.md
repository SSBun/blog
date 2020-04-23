---
title: Swift 中的修饰器 @propertyWrapper
date: 2020-02-18 12:47:19
tags:
- Swift
---

我们知道在 Python 中对属性方法都可以使用`修饰器`，修饰器能够监听、处理被修饰的属性或方法。这在处理一些普遍的逻辑时，能够让代码看起来更加的清晰和简洁，例如：获取用户信息前，需要用户先登录，而判断用户登录的逻辑，就无须写入获取用户信息的方法里，直接在外部使用修饰器就能够预先判断，并执行相应的逻辑，而在查看代码时，一眼就能看出这个方法需要让用户先登录。而实现这样的功能，必须依赖编译器的支持，现在 Swift5.1 提供了 `@propertyWrapper` 来实现部分修饰器的功能，如它的名字所示，它是一个**对属性的包装**。接下来我们来看一下这个 `@propertyWrapper`是如何使用的，在某些场景下，它能让我们的代码变的无比的简洁。

`@propertyWrapper` 可以用来修饰一个 `struct` 或 `class`，而被修饰的对象必须要有一个属性 `wrappedValue` 用来表示被包裹的值。接下来我们看一个例子：

```Swift
@proeprtyWrapper struct Capitalized {
    var wrappedValue: String {
        didSet { wrappedValue = wrappedValue.capitalized() }
    }
    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.capitalized()
    }
}
```

以上我们就将 `Capitalized` 声明成了一个 `propertyWrapper`，它会被修饰的字符串变成首字母大写的形式。我们看看如何使用：

```Swift
struct Person {
    @Capitalized
    var name: String
}

let me = Person(name: "csl")
print(me.name) // Csl
```

可以看出在 `name` 被赋值的时候其实是给 `Capitalized` 内部的 `wrappedValue` 赋值，然后我们将其首字母大写。这种写法显然比到处在 `setter` 方法里面写逻辑好了，并且是声明式的写法，在阅读代码时也能一目了然。

显然 `@propertyWrapper` 构建的 Wrapper 也可以设置多个参数，来对包含的 `wrappedValue` 进行更详细的描述。而最容易想的例子当然就是 `UserDefaults`, 在设置页面，通常会用一些状态属性来控制和存储用户的设置值，通常我们会通过 setter 和 getter 来监听值的变化，然后通过 `UserDefaults` 进一步持久化数值。接下来我们看看用 `@propertyWrapper` 该如何实现相应的功能呢:

```Swift
@propertyWrapper struct UserDefaultsBacked<Value> {
    let key: String
    var storage: UserDefaults = .standard
    var defaultVaue: Value
    
    var wrappedValue: Value {
        set {
            storage.setValue(newValue, forKey: key)
        }
        get {
            storage.value(forKey: key) as? Value ?? defaultVaue
        }
    }    
}

class SettingsViewController  {
    @UserDefaultsBacked(key: "darkMode", defaultValue: false)
    var isDarkMode: Bool

    private func toggleDarkMode() {
        // Update UI
        // ......

        isDarkMode.toggle()
    }
}
```

以上是我们在设置页面进行状态切换时，`darkMode` 的值会直接通过 `UserDefaults` 进行保存。有时候有些值可能就是 nil，我们在设置默认值的时候总是需要设置 nil 太繁琐，所以这里可以为 `UserDefaultsBacked` 添加一个扩展

```Swift
extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = .standard) {
        self.init(key: key, storage: storage, defaultVaue: nil)
    }
}
```

这样在包装一个 Optinal 值的时候就不用再写 default 值为 nil 了

```Swift
class SettingViewController {
    @UserDefaultsBacked(key: "userName")
    var userName: String?
}
```

但是上述的写法还有一个问题，就是当我们给可选类型的属性赋值 nil 时，`storage.setValue(newValue, forKey: key)` 会产生一个错误，然后崩溃，我们需要判断 `newValue` 是否为 nil，然而通过 `newValue == nil` 是无法判断的，因为泛型 `Value` 不是一个可选值，虽然 Value 实际值可能是一个可选值并为nil，但编译器在编译期间就会警告它们两个比值一定是 false。所以这里我们在通过一个协议来扩展一个属性 `isNil` 来判断是否为 nil

```Swift
@propertyWrapper struct UserDefaultsBacked<Value> {
    let key: String
    var storage: UserDefaults = .standard
    var defaultVaue: Value
    
    var wrappedValue: Value {
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.setValue(newValue, forKey: key)
            }
        }
        get {
            storage.value(forKey: key) as? Value ?? defaultVaue
        }
    }
}

extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = .standard) {
        self.init(key: key, storage: storage, defaultVaue: nil)
    }
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

```

然后我们就可以直接给被标记赋值为 nil 就能从 UserDefaults 删除此值了。

如果你对 SwiftUI 有一些了解的话，那对 `@State` 肯定不陌生，这些标记并不是 SwiftUI 专用的，他们其实就是 `@proeprtyWrapper`, 而使用这些属性的时候，我们有时候会用美元符`$`来调用，这是什么时候呢，用 `$` 符调用的时候其实是调用了 `propertyWrapper`里面的 `projectedValue` 属性，这里的 `$` 更像是一个语法糖，不管 SwiftUI 如何使用，但是实际的作用就是,直接调用映射属性是 `wrappedValue`  使用 `$` 符号映射属性是 `projectedValue`.




