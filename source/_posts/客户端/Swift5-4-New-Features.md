---
title: Swift5.4 New Features
date: 2021-05-07 14:26:26
tags:
- Swift
---

In the last article, we have understood the result builder transforms. There're some other small changes in the new Swift version.

## Implicit Conversion to a Pointer Type

Seeing the example:
```Swift
func unsafeFunc(_ value: UnsafePointer<Int>) {

}

var age = 100
```
In this example, I wanna pass the age value to the function `unsafeFunc`. But the unsafeFunc is receiving an `UnsafePoint<Int>` type value. 
Int the past, We can use the function `withUnsafeMutablePointer` to convert the variable age to an UnsafePoint value. Just like this:

```Swift
withUnsafeMutablePointer(to: &age) {
    unsafeFunc($0)
}
```
But now, new version Swift can automatically converts an inout value to an UnsafePoint value. So you can pass a inout value `&age` to invoke the function `unsafeFunc`. The two function calls are equivalent.

```Swift
unsafeFunc(&age)
```

## Multiple Variadic Parameters

Now that a function can have multiple variadic parameters. 

```Swift
func myZip<A, B>(leftValues: A..., rightValues: B...) -> [(A, B)] {
    Array(zip(leftValues, rightValues))
}

myZip(leftValues: 1, 2, 3, rightValues: "one", "two", "three")
```

## Improved Implicit Members syntax

Swift has always had the ability to use implicit member syntax for simple expressions. But it can't support some complex scenes. Like you want to setup a transparent color for the background color of a view in SwiftUI. If the color is opaque. Your code likes this: 

```Swift
struct ContentView: View {
    var body: some View {
        Text("Hello World!")
            .backgroundColor(.red)
    }
}
```

But if the color has a little transparence, we want to write the code `.red.opacity(0.7)` to do this. Unfortunately, before the Swift5.4 the compiler would throw a syntax error. But now, we can do it. 

There's another common situation that assigning an optional value. When you assign a value using implicit member syntax to an enum optional type variable, the compiler will display two syntax completions `.some()` and `.none` in the past. Now the compiler will remind all options containing all the enums.

```Swift
enum Animal {
    case cat
    case dog
}

var myPet: Animal? = .cat
```

## Local functions now support overloading

For example, you can write code like this:

```Swift
func test() {
    func eat(number: Int) {
    }
    
    func eat(string: String) {
    }
    
    eat(number: 1)
    eat(string: "1")
}
```

## Now the `PropertyWrapper` supported for local variables

In the previous article [Swift 中的修饰器 @propertyWrapper](http://csl.cool/2020/02/18/%E5%AE%A2%E6%88%B7%E7%AB%AF/Swift-%E4%B8%AD%E7%9A%84%E4%BF%AE%E9%A5%B0%E5%99%A8-propertyWrapper/), we made a property wrapper `UserDefaultsBacked` for setting `UserDefaults` quickly and concisely. Now we can declare a local variable with a Property Wrapper.

There are some limits compared with properties. When we use the propertyWrapper on a property, we can custom some properties for the PropertyWrapper and initialize these when using it

```Swift
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

But when we use it in a local variable. We must initialize the variable when declaring it. And we have to implement the function `init(wrappedValue: Value)` for our PropertyWrapper. So that you can initialize the local variable. We can't initialize any custom properties for the PropertyWrapper like above.

```Swift
@propertyWrapper struct Box<Value> {
    var value: Value
    
    var wrappedValue: Value {
        set {
            value = newValue
        }
        get {
            value
        }
    }
    
    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}

func testPropertyWrapper() {
    @Box
    var age: Int = 100
    
    age = 100
    print(age)

    // These code can't pass compilation.
    @UserDefaultsBacked(key: "darkMode", defaultValue: false)
    var isDarkMode: Bool
    // or
    var isDarkModel: Bool = false
}
```
