---
title: 'Procedure-Oriented, Object-Oriented, Functional, Protocol-Oriented'
date: 2021-06-17 15:08:24
tags:
marks:
- Unfinished:red
---

Being coding, we will find we have several kinds of programing pattern. The most common types of them are Procedure-Oriented, Object-Oriented, Functional and Protocol-Oriented. Let's explore the differences between them and think about that where we should use them.

## Procedure Oriented Programing
At the beginning of learning programming, we usually start with C language. The C is a Procedure-Oriented  programing language. **When we use C, we parse a question to several steps and code some methods for them. We resolve the question by executing these methods in a certain order.** We care about the concrete steps of resolving questions.

In this article, we take an example about that a dog eats food and then begin to bark. In Procedure-Oriented programming, we may write code like this:

```Swift
func dogEatsFood() {}
func dogBarks() {}

func main() {
    // First
    dogEatsFood()
    // Second
    dogBarks()
}
```

## Object Oriented Programing
In modern programing languages like Java, Objective-C, Swift, C++, etc.., all of them import the concept `Class` and encourage everyone to use Object-Oriented programing. In most cases, the question we are solving is a real world problem, we can parse the relationships in this problem and extract them to classes. One class is a specific object, the properties of the class is the characters of the object, the methods of the class is the actions of the object, so the example above would rewrite to this:

```Swift
class Dog {
    func eatFood() {}
    func bark() {}
}

func main() {
    let dog = Dog()
    dog.eatFood()
    dog.bark()
}
```

OOP (Object-Oriented Programing) has four features we should know:

- Encapsulation
We extract an object as a new class or encapsulate a group of actions to a function. To the outside, the detail implementation of these functions is hidden. Executing a function, users don't need to know how it is implemented, only what it does.
- Inheritance
`Inheritance` is a very important concept to Class, the sub class can inherit the properties and functions of the super class, they can reuse the same codes. 
- Polymorphism`
    - `Overload Method` Declaring several methods that has same function name and different parameter types or count. When you invoke the same method, the really implementation of the function depends the parameters passed.
- Abstraction
`Abstraction` is a special concept. In some programing language you can declare an abstract class, the class just declare the functions without implementing them. You need create a sub class inheriting it to implement these functions. In most of the time, we extract a new class form multiple classes that have relationships together. (eg: extract a class `Animal` from classes `Dog`, `Cat`, `Fish`, etc...).

## Functional Programing
Functional Programing is a very popular concept in recent years, and many people have themselves viewpoint. After querying various articles, we know the functional programing should be a mapping, an expression. We input the same variable and always get the same return value. In the executing process, we don't modify any outside variables, parameters or properties. Maybe you heard that the functional programing is to describe the data what you want, not to compute it like Procedure-Oriented programing, But what's it means? Let's look an example.

We want to calculate the accumulation form 1 to 100.
```Swift
func cumulate(from Int, to Int) -> Int {
    var sum = 0;
    for i in from...to {
        sum = sum + i
    }    
    return sum
}
```
We can write code above easily. We describe the concrete steps how to calculate the final result. If we use functional programing ?

```Swift
func cumulate(from Int, to Int) -> Int {
    if from >= to { return 0 }
    return from + cumulate(from + 1, to)
}
```

We just declare two situations, one is the from number is equal or greater to the to value, this time we return the zero. the second situation is adding the from value with the rest of the cumulation. **We don't know how to calculate the sum, but we know what constitutes the sum.**

## Protocol Oriented Programing

There are no many people knowing or using the POP. In Objective-C, we know it has a special type `Protocol`, the `Protocol` is 
very similar to the `Abstract Class`. A protocol can't be instanced, it's a diagram used to describe what properties and actions a special object have to had. 

Apple claim that `at its heart, Swift is protocol-oriented`, so we can find that all of the classes, structures and enumerations can adopt the protocols. We use a protocol to extract the similar data structures, these classes have some same functions or properties, like the cats and dogs are all the animals, we can extract a protocol `Animal` and define the property `age` and function `eat`, etc...

Using the protocol can make us extract the most important properties and functions from the classes, the classes of our project would be more clear and tidy, avoid writing some needless properties and functions. Because when you declare a protocol, you always think about try to use the fewest properties and functions to describe the class you need as far as possible, these thoughts come naturally. It's very flexible because the protocol only describe a class, any classes adopting the protocol can be free interchangeable, this makes the entire project code more stable and flexible in case of requirement changes.

```Swift
protocol Animal {
    var age: Int { get }
    eat()    
}

class Dog {
    let age: Int
    eat() {

    }
}

class Cat {
    let cat: Int
    eat() {

    }
}
```