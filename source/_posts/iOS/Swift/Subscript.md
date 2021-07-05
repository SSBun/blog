---
title: Swift - Subscript
date: 2017-10-17 11:29:54
tags:
- Swift
categories:
- iOS
---

## 下标语法

下标允许你查询一个类型的实例，通过在这个类型的实例名后添加一个方括号，并在括号内写入一个或多个值。这些语法与所有的实例方法以及计算属性的语法类似。你可以通过 subscript 关键字来定义一个下标，然后指定一个或多个参数并提供一个返回值类型，与实例方法相同。不同于实例方法的是，下标可以被设置为读写或是只读。这种行为是通过设置 getter 和 setter 来实现的，和计算属性一样。

```swift
subscript(index: Int) -> Int {
    get {
        // return an appropriate subscript value here
    }
    set(newValue) {
        // perform a suitable setting action here
    }
}
```

setter 方法中的 newValue 和下标的返回值类型相同。类似于计算属性，你不必为 setter 方式指定一个参数名 (newValue)， 如果没有写一个新的参数名的话，系统会提供一个默认的方法名就就叫做 newValue。

和只读的计算属性一样，你可以丢弃 get 关键字来实现一个只读的下标操作：

```swift
subscript(index: Int) -> Int {
    // return an appropriate subscript value here
}
```

这个有一个只读下标的实现，它定义了一个结构体 TimesTable 来代表一个整数乘法表：

```swift
struct TimesTable {
    let multiplier: Int
    subscript(index: Int) -> Int {
        return multiplier * index
    }
}
let threeTimesTable = TimesTable(multiplier: 3)
print("six times three is \(threeTimesTable[6])")
// Prints "six times three is 18"
```

在这个例子中，TimesTalbe 生成了一个新的实例 threeTimesTalbe, 代表这乘数为3的乘法表。它通过结构体的初始化方法传入一个参数3，作为这个乘法表的乘数。

你可以通过一个下标来查询这个乘法表，就像上面调用 threeTimesTable[6] 的方式一样。传入一个下标3进入这个乘法表，就回得到一个返回值18，也就是 3 \* 16。

## 下标的使用

下标的确切含义取决于它使用的上下文。下标通常被用作访问一个集合、列表或序列的成员的快捷操作。你可以自由的使用下标，通过合适的方式来实现特定的类或是快捷方法。

例如，Swift 中的 Dictionary、Array 类型通过实现下标来设置和检索一个字典实例。

```swift
var numberOfLegs = ["spider": 8, "ant": 6, "cat": 4]
numberOfLegs["bird"] = 2

var tempArr = [1,2,3,4]
tempArr[0] = 100
```

## 下标的选择

下标可以传入任意多个参数，这些参数可以是任意的类型。下标也可以返回任意的类型。 下标参数可以使用变量 (variadic parameters)，但是不能使用 in-out 参数或是提供给下标一个默认值。

一个类、枚举或结构体可以提供任意多种的下标实现。一个合适的下标可以让我们可以通过下标中的值及值的类型来推测出其意义。这种多重的下标定义被称作 subscript overloading 。

大多数的下标都是只提供一个参数，当然只要适合于你的类型，你可以定义一个多参数下标。接下来的例子定义了一个结构体 Matrix ， 它代表一个 Double 类型的2维数矩阵。Matrix 的下标就是两个参数。

```swift
struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}
```

Matrix 提供了一个构造方法，传入两个参数分别是行和列。 内部初始化了一个 Double 数组，数组里面有 row \* colum 个元素，元素的初始值都是0.0。你可以构建一个新的二维矩阵通过传入行列的个数。

```swift
var matrix = Matrix(rows: 2, columns: 2)
```

上面这个创建的二位矩阵有2行2列。其属性 grid 数组是这个二维矩阵的展开形式

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119155405.png)

你可以通过给矩阵 matrix 传入下标参数来检索和设置它的值，下标通过逗号分隔，分别传入行数和列数。

```swift
matrix[0, 1] = 1.5
matrix[1, 0] = 3.2
```

上面的两个声明调用了下标的 setter 方法，将矩阵的左上方（0行1列）赋值为 1.5，将矩阵的右下方（一行0列）赋值为 3.2。

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119155426.png)
