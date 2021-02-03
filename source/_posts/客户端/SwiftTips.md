---
title: SwiftTips
date: 2020-02-20 15:13:16
tags:
- iOS
categories:
- Swift tips
marks:
- 持续更新:blue
---

> Swift 中的正常操作！！！

## 传入 KeyPath 作为函数

> Swift 5.2新特性，使用 map 等函数来进行数据转换时是更加简洁了，一个小小的改动。

```Swift
struct Movie {
    var name: String
    var isFavorite: Bool
    ...
}

let movies: [Movie] = loadMovies()

// Equivalent to movies.map { $0.name }
let movieNames = movies.map(\.name)

// Equivalent to movies.filter { $0.isFavorite }
let favoriteMovies = movies.filter(\.isFavorite)
```

## 使用 keypath 来匹配 switch

> Swift 的 switch 已经如此强大了，配合 ~= 符号能让我们实现更强大的 switch

```Swift
func ~=<T>(lhs: KeyPath<T, Bool>, rhs: T) -> Bool {
    rhs[keyPath: lhs]
}

func handle(_ character: Character) {
    switch character {
    case "<":
        parseElement()
    case "#":
        parseHashtag()
    case \.isNumber:
        parseNumber()
    case \.isNewline:
        startNewLine()
    default:
        parseAnyCharacter()
    }
}
```

## 计算属性和有返回值方法中如果自有一个表达式可以省略 return

> 好用

```Swift
extension MarkdownReader {
    var isAtStart: Bool { index == string.startIndex }
    var didReachEnd: Bool { index == string.endIndex }
    var currentCharacter: Character { string[index] }
    
    func encodeCurrentCharacter() -> String {
        currentCharacter.encoded()
    }
}
```

## Swift5.1 中枚举的关联值也可以使用默认参数

> 撒花

```Swift
// Associated enum value defaults are specified the same way as
// default function arguments:
enum Content {
    case text(String)
    case image(Image, description: String? = nil)
    case video(Video, autoplay: Bool = false)
}

// At the call site, any associated value that has a default
// can be omitted, and the default will be used:
let video = Content.video(Video(url: url))
```

## 使用元组成组的捕获异常

> 如果遇见调用多个会抛出一样的函数，可以使用元组将其括起来，那样的话你就只需写一个 try。

```Swift
// Here we have three highly related expressions that are
// all throwing, requiring separate assignments and separate
// 'try' keywords:
let contentFolder = try Folder.current.subfolder(named: "content")
let templatesFolder = try Folder.current.subfolder(named: "templates")
let output = try Folder.current.createSubfolderIfNeeded(withName: "output")

// By combining them all into a tuple, we only need one
// 'try', and can easily group our data into a single,
// lightweight container:
let folders = try (
    content: Folder.current.subfolder(named: "content"),
    templates: Folder.current.subfolder(named: "templates"),
    output: Folder.current.createSubfolderIfNeeded(withName: "output")
)

// The call sites also become really nice and clean, with
// increased "namespacing" for our local variables:
readFiles(in: folders.content)
loadTemplates(from: folders.templates)
```

## 用函数来联合变量

> 最后我们将生成一个无参闭包，针对一些闭包 API 可以直接传递，并且不需要在闭包当中捕获 self。

```Swift
func combine<A, B>(_ value: A, with closure: @escaping (A) -> B) -> () -> B {
    return { closure(value) }
}

// BEFORE:

class ProductViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        buyButton.handler = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.productManager.startCheckout(for: self.product)
        }
    }
}

// AFTER:

class ProductViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        buyButton.handler = combine(product, with: productManager.startCheckout)
    }
}
```

## 善用方法作依赖注入

> 如果需要注入的依赖并不复杂，就不允许使用协议或是导入整个 Model 了。

```Swift
final class ArticleLoader {
    typealias Networking = (Endpoint) -> Future<Data>
    
    private let networking: Networking
    
    init(networking: @escaping Networking = URLSession.shared.load) {
        self.networking = networking
    }
    
    func loadLatest() -> Future<[Article]> {
        return networking(.latestArticles).decode()
    }
}
```

## 解包可选值失败时可以抛出一个异常

> 不用修改方法本身，就能将其改造成一个可以抛出异常的 API

```Swift
extension Optional {
    func orThrow(_ errorExpression: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            throw errorExpression()
        }
    }
}

let file = try loadFile(at: path).orThrow(MissingFileError())
```

## 自定义 UIView 的 layer

> 这样的话就可以自定义许多有趣的 View 了，不用添加多余的 layer，不用管理 layer 的布局，就像一个系统的 view 一样。

```Swift
final class GradientView: UIView {
    override class var layerClass: AnyClass { return CAGradientLayer.self }

    var colors: (start: UIColor, end: UIColor)? {
        didSet { updateLayer() }
    }

    private func updateLayer() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = colors.map { [$0.start.cgColor, $0.end.cgColor] }
    }
}
```

## 如果枚举的关联类型遵守 Equatable 则枚举自动遵守 Equatable

> 看起来很合理

```Swift
struct Article: Equatable {
    let title: String
    let text: String
}

struct User: Equatable {
    let name: String
    let age: Int
}

extension Navigator {
    enum Destination: Equatable {
        case profile(User)
        case article(Article)
    }
}

func testNavigatingToArticle() {
    let article = Article(title: "Title", text: "Text")
    controller.select(article)
    XCTAssertEqual(navigator.destinations, [.article(article)])
}
```

## 元组类型的解构

> 在 Swift 中，元组类型在赋值时可以像其他语言那样使用解构

```Swift
class ImageTransformer {
    private var queue = [(image: UIImage, transform: Transform)]()

    private func processNext() {
        // When unwrapping an optional tuple, you can assign the members
        // directly to local variables.
        guard let (image, transform) = queue.first else {
            return
        }

        let context = Context()
        context.draw(image)
        context.apply(transform)
        ...
    }
}
```

## 嵌套泛型类型

> 嵌套的泛型类型，能够继承上层类型的泛型定义，这样省去了重复定义相同类型泛型的麻烦。

```Swift
struct Task<Input, Output> {
    typealias Closure = (Input) throws -> Output

    let closure: Closure
}

extension Task {
    enum Result {
        case success(Output)
        case failure(Error)
    }
}
```

## alias 也能用泛型

> 看起来似乎有一些用处

```Swift
typealias Pair<T> = (T, T)

extension Game {
    func calculateScore(for players: Pair<Player>) -> Int {
        ...
    }
}
```

## 为类型扩展静态工厂方法

> 在构建 UI 时非常的有用，特别是对统一设计风格的通用 UI 来说，高度封装，使得对 UI 的修改变的简单，代码也更加的简洁，如果配合上点语法就更完美了。

```Swift
extension UILabel {
    static func makeForTitle() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .darkGray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
    }

    static func makeForText() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }
}

class ArticleViewController: UIViewController {
    lazy var titleLabel = UILabel.makeForTitle()
    lazy var textLabel = UILabel.makeForText()
}
```

## 将实例方法当做静态方法来调用

> 同样是对函数式编程的实践

```Swift
// This produces a '() -> Void' closure which is a reference to the
// given view's 'removeFromSuperview' method.
let closure = UIView.removeFromSuperview(view)

// We can now call it just like we would any other closure, and it
// will run 'view.removeFromSuperview()'
closure()

// This is how running tests using the Swift Package Manager on Linux
// works, you return your test functions as closures:
extension UserManagerTests {
    static var allTests = [
        ("testLoggingIn", testLoggingIn),
        ("testLoggingOut", testLoggingOut),
        ("testUserPermissions", testUserPermissions)
    ]
}
```

## 在 for-loop 循环中使用 where

> 如果你需要在循环中使用 if 来筛选数据，那不妨使用 where 来让代码的结构更加清晰

```Swift
func archiveMarkedPosts() {
    for post in posts where post.isMarked {
        archive(post)
    }
}

func healAllies() {
    for player in players where player.isAllied(to: currentPlayer) {
        player.heal()
    }
}
```

## 使用点语法来访问静态方法、静态变量和构造方法

> 省略类型，直接使用点语法访问，用在 API 和默认值上时，让代码开起来无比的简洁

```Swift
public enum RepeatMode {
    case times(Int)
    case forever
}

public extension RepeatMode {
    static var never: RepeatMode {
        return .times(0)
    }

    static var once: RepeatMode {
        return .times(1)
    }
}

view.perform(animation, repeated: .once)

// To make default parameters more compact, you can even use init with dot syntax

class ImageLoader {
    init(cache: Cache = .init(), decoder: ImageDecoder = .init()) {
        ...
    }
}
```

## 在 enum 和 struct 的构造方法里面可以直接设置 self

> class 中我们只能设置 self 的属性，而在 enum 和 struct 中我们能设置 self 的值，这样的话我们就能很方便的为它们扩展各种便利构造方法了。

```Swift
extension Bool: AnswerConvertible {
    public init(input: String) throws {
        switch input.lowercased() {
        case "y", "yes", "👍":
            self = true
        default:
            self = false
        }
    }
}
```

## `ExpressibleBy...` 系列函数的使用

> 一定要确保使用时语义清楚，特别是针对自定义类型，否则一段时间后，你都未必知道它到底做了什么

```Swift
extension URL: ExpressibleByStringLiteral {
    // By using 'StaticString' we disable string interpolation, for safety
    public init(stringLiteral value: StaticString) {
        self = URL(string: "\(value)").require(hint: "Invalid URL string literal: \(value)")
    }
}

// We can now define URLs using static string literals 🎉
let url: URL = "https://www.swiftbysundell.com"
```

## 闭包类型用来做泛型约束

> 闭包类型也是类型，作为 Swift 中的第一公民，当然也能用来做泛型约束啦

```Swift
extension Sequence where Element == () -> Void {
    func callAll() {
        forEach { $0() }
    }
}

extension Sequence where Element == () -> String {
    func joinedResults(separator: String) -> String {
        return map { $0() }.joined(separator: separator)
    }
}

callbacks.callAll()
let names = nameProviders.joinedResults(separator: ", ")
```

## 将一组方法合并起来

> 在函数式编程当中，就是所谓的管道函数 `|>`

```Swift
internal func +<A, B, C>(lhs: @escaping (A) throws -> B,
                         rhs: @escaping (B) throws -> C) -> (A) throws -> C {
    return { try rhs(lhs($0)) }
}

public func run() throws {
    try (determineTarget + build + analyze + output)()
}
```

## 使用 `map` 和 `flatMap` 来优化可选链

> Swift 中的可选链可真是简洁代码杀手，我们总是会陷入 `if let 和 gaurd let` 的解包泥潭中去，不过在单一参数的情况下，我们可以利用 `map` 和 `flatMap`来简化我们的可选链代码

```Swift
// BEFORE

guard let string = argument(at: 1), let url = URL(string: string) else {
    return
}

handle(url)

// AFTER

argument(at: 1).flatMap(URL.init).map(handle)
```

## 使用可变参数

> 如果你的 API 需要传入一组手动创建的数据，使用可变参数要比使用数组看起来更合理。

```Swift
public extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach(self.addSubview(_:))
    }
}
```

## 有关联值的 enum 类型，在不存入关联值的时候是一个闭包

> 看来枚举是函数式编程和柯里化的忠实粉丝啊！

```Swift
enum UnboxPath {
    case key(String)
    case keyPath(String)
}

struct UserSchema {
    static let name = key("name")
    static let age = key("age")
    static let posts = key("posts")
    
    private static let key = UnboxPath.key
}

print(type(of: UnboxPath.key)) // (String) -> UnboxPath
```


## 初始化方法可被用来设置参数和闭包的默认值

> 如果用的到的话，代码看起来会更简洁明了

```Swift
class Logger {
    private let storage: LogStorage
    private let dateProvider: () -> Date
    
    init(storage: LogStorage = .init(), dateProvider: @escaping () -> Date = Date.init) {
        self.storage = storage
        self.dateProvider = dateProvider
    }
    
    func log(event: Event) {
        storage.store(event: event, date: dateProvider())
    }
}
```


## 利用 #function 将属性名指定为 UserDefault 的 key

> 灵魂操作！！！

```Swift
extension UserDefaults {
    var onboardingCompleted: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
```

## 类型名称与系统框架内类型名称重复

> 首先尽量不用使用与系统内部框架重名的标识符，当然如果你非要用，可以使用 `Swift.` 来为系统类型指定命名空间

```Swift
extension Command {
    enum Error: Swift.Error {
        case missing
        case invalid(String)
    }
}
```

## 善用 typealias 来减少类型名的长度

> 首先，就像在 OC 中一样用 typealias 来声明长长的闭包类型。其次嵌套类型的名称往往很长，如果需要用到了一个其他类型嵌套下的子类型时，不妨在当前作用域给它起一个短别名。

```Swift
public class PathFinder<Object: PathFinderObject> {
    public typealias Map = Object.Map
    public typealias Node = Map.Node
    public typealias Path = PathFinderPath<Object>
    
    public static func possiblePaths(
        for object: Object,
        at rootNode: Node,
        on map: Map
    ) -> Path.Sequence {
        return .init(object: object, rootNode: rootNode, map: map)
    }
}
```

## 自动闭包

> 如果你的方法中有一个参数需要耗时计算才能得到，而这个参数**可能不会被使用或是不会被立即使用**,这个时候我们应该使用 `@autoclosure`将其转换成一个闭包。这样即保证了调用形式和原来一样，也能够保证仅在需要的时候才去运算获取相应的值。

```Swift
// Swift 中的 || 就是这样实现的，如果左侧为 ture 就不用再费力执行右侧的结果了。
public static func || (lhs: Bool, rhs: @autoclosure () throws -> Bool) rethrows -> Bool {
    if lhs {
        return true
    } else {
        return try rhs()
    }
}
```

## 使用嵌套类型实现命名空间

> 很常用，例如一个特殊 API 返回的数据类型不通用，但是又想使用 Model 的便利性，此时创建一个全局的 Model 就太过浪费了，在当前类型的作用域下创建一个 Model 是一个不错的方法。当然也包括了 UI 模块，一个 UI 模块内部的更小模块，无须占用全局的类型名称，可以创建在当前模块的作用域下。

```Swift
public struct Map {
    public struct Model {
        public let size: Size
        public let theme: Theme
        public var terrain: [Position : Terrain.Model]
        public var units: [Position : Unit.Model]
        public var buildings: [Position : Building.Model]
    }
    
    public enum Direction {
        case up
        case right
        case down
        case left
    }
    
    public struct Position {
        public var x: Int
        public var y: Int
    }
    
    public enum Size: String {
        case small = "S"
        case medium = "M"
        case large = "L"
        case extraLarge = "XL"
    }
}
```
