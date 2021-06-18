---
title: iOS Reviews Questions
date: 2021-06-07 17:02:31
tags:
marks:
    - Unfinished:red
---

> **References:**
>  [iOSInterviewQuestions](https://github.com/ChenYilong/iOSInterviewQuestions)

## Why Apple suggest using `NS_ENUM` or `NS_OPTIONS` to declare an enum?

**In Objective-C, we can declare an enum with three ways.**
![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210607171859.png)

### The differences between them:

1. First, we can find that the `DogType` and the `BirdType` specify an underlying type `NSInteger` for themselves. But the `CatType` doesn't specify any special type. In this situation, the compiler will decide the base type whatever he like. (maybe: char, short, or even a 24 bit integer)

2. Second, the compiler specifically recognizes the NS_ENUM macro, so it knows that you have an enum with values that shouldn't be combined like flags, the debugger knows what's going on, and **the enum can be translated to Swift automatically.**

### If we use them in Swift, what will happen?

1. When declaring an `CatType` enum , we will find that the `CatType` isn't an enum type in Swift. It's transformed to an alias of `UInt32`.
![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210607173309.png)
The cases `CatTypeOne` and `CatTypeTwo` are actually two UInt32 numbers.

2. The enum `DogType` is much better, Swift compiler would transform it to an true enum type.
![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210607173929.png)
But if we want to use its case, you wil find there are some questions when writing. We can't define a case like `DogType.one`. The compiler didn't help us transform these OC enum cases to Swift form. You can only use them like using an OC form enum.
![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210607174212.png)
Of course you can write an extension for it, then you can use it as using a real Swift enum. (`var dog: DogType = .one`) You can use the initialization method `let dog4 = DogType.init(4)` to declare an new case.
![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210607175247.png)

3. If you use `NS_ENUM` to declare an enum in OC, you need to do nothing when using in Swift. The Swift compiler would completely transform it to a Swift enum.

So make sure you use `NS_ENUM` to declare your enums in OC, then can freely use them in OC or Swift files without any transformations.

## Why suggest using `instancetype` to replace `id` as the return type of init methods?

> [There is the answer of the Apple Official](https://www.notion.so/iOS-Interview-Question-891d5d1bfdda466584523419588173f0#387f7d6d27b04b2880fb51c1714c56c0)

In the early, we all know the return type of constructors and factory methods was `id`. Why use `id` instead of certain type? This is because OC is an Object-Oriented language. A sub class will inherit the constructors of its super class. If we initialize an instance by the sub class, the actual return value of the constructor is a sub class instance, so we can't use an certain type to define the return value type, we need a general type can references all object types. 

But there are some questions we can't resolve, the first is we can invoke a method the class doesn't have and the compiler warns nothing, the app will crash when running to this code.
![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210607185321.png)
The class `TestModel` doesn't have a method or property named `length`. The reason we can invoke this method is the instance is an id type and the `id` type can invoke all methods of all classes in the project.

Afterwards, Apple provides a new type `instancetype` to replace the `id` type. The `instancetype` is not a certain type or a general type like `id`, it's just a compiler flag. It can only be used as the return value type of functions. We invoke the constructor again after changing the return value type to `instancetype`, the return value won't be an `id`type, it becomes the certain type as same as the class invoked. Then the compiler can display correct code hints and display warning message when you invoke error methods.
This is why we should use `instancetype`, not `id`.

## In which situation should we use the `weak` keyword? What are the differences compared with the `assign`?

### In which situation should we use the `weak` keyword?
1. In `ARC`, we will mark one side with `weak` keyword when there are possibly any cycle reference in some particular scenes. (eg: `delegate`)
2. In some particular scenes, the object will be referenced by `"itself"`, we don't need to reference it twice. For example, we can declare `IBOutlet` controls properties with `weak`. This is because there is a private `_topLevelObjectsToKeepAliveFromStoryboard` array in the `ViewController` created by storyboard(not xib), the array would references all top level objects.

### What are the differences compared with `assign`?
1. Firstly, the modifier `assign` can declare non-object types, but the `weak` must be used to declare object types.
2. When we assign a value to a property declared with the `weak`, the old object referenced by the property won't perform the `release` action and the new object assigned to the property won't perform the `retain` action. In this case, the `assign` and `weak` have the same behaviors. The difference between them is that the weak property will be `nil` when the object referenced by it was released. The modifier `assign` is used to declare scaler types (eg: CGFloat, Int, Double, Bool), the setting method of it just perform the easiest assigning action.

## How to use the keyword `copy`?

### Usages:
1. `NSString, NSArray, NSDictionary` usually use the keyword `copy`, because they have the corresponding mutable types, `NSMutableString, NSMutableArray, NSMutableDictionary`.
2. The `block` also often use the keyword `copy`. **Concrete Reason: [Objects Use Properties to Keep Track of Blocks](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html#//apple_ref/doc/uid/TP40011210-CH8-SW12)**

Using `copy` to decorate a block is a legacy from MRC. In MRC, the block created in function is in the stack area, we need to copy it to the heap area. But this isn't something you need to worry about when using ARC, it will happen automatically.

In ARC, the copying action will be performed automatically in these situations:
1. `block` as functions' return value
2. Assign a block to a `__strong` reference pointer.
3. As a parameter of a Cocoa API function that's name contains the string `using Block`.
4. As the function parameters of GCD API.

> Of course you can decorate a block with the modifier `strong`, it's OK. But it’s best practice for the property attribute to show the resultant behavior.

## Are there any question when you write like this `@property (copy) NSMutableArray *array`?
- The first, you use the modifier `copy` to decorate a mutable type, when you assign a value to the property array, it will copy the mutable array and transform it to an immutable array in the **setter function**. At the moment, if you invoke a mutable array's function (eg: insert) to the property array, you will get a crash because the function cannot be found.
- The second, Using `atomic` would heavily depress the App's performance. There isn't an modifier named `atomic`, so if you don't mark one property with `nonatomic`, the property will be `atomic`.

### Why do not suggest declaring an atomic property?
We know the purpose of using the modifier `atomic` is for multithread safe, the compiler will generate some additional code to keep thread safe, it'll bring some performance troubles. Unfortunately, just using the `atomic` can't achieve ours aim to implement thread safe, we need a more deeper locking mechanism.

## How to make our custom classes can use the modifier `copy`? How to overwrite the setter method of the copying property?

If you want to define a yourself class can be copy, your class needs to abide by the `NSCopying` protocol. If your class has two forms, mutable and immutable, you must abide by two protocols `NSCopying` and `NSMutableCopying` at the same time.

**Detail steps:**
1. Declare the class abiding by the protocol.
2. Implement the protocol method `-(id)copyWithZone:(NSZone *)zone`.


## What is the essence of the modifier `@property`? How to generate `ivar` ,`getter` and `setter` and insert them to classes?

> @property = ivar + getter + setter

`Property` is a feature of Objective-C, its mainly purpose is to encapsulating the data in the class. Objective-C usually uses various instance variables to store data. And then using the accessing method to set or get data from instance variables. This feature was introduced in Objective-C 2.0. In formal Objective-C coding specification, the getter and setter method have strict naming conventions, so the compiler can help us automatically generate the accessing functions.