---
title: Kingfisher 源码解读
date: 2020-11-03 14:29:22
tags:
- iOS
- Swift
- SwiftUI
---

`Kingfisher` 是喵神开源的一个图片加载框架，能够加载网络，本地的多种格式的图片，并提供了缓存和动画的支持，随着 SwiftUI 的发布，`Kingfisher` 也增加了对 SwiftUI 的扩展。最近的 iOS Widget 项目中正好使用了 SwiftUI，借此机会学习一下 Kingfisher 各个部分的实现以及对 SwiftUI 的封装。

> **此处使用的版本**  
> Github address: [Kingfiher](https://github.com/onevcat/Kingfisher)  
> Tag: 5.15.7

## Kingfisher 的主要模块?

### kf 命名空间

在使用 `Kingfisher` 的时候我们能发现所有的 API 调用都会使用"前缀" `kf` 来调用，例如 `UIImageview` 等可以调用 API 的组件都通过扩展拥有了一个 `kf` 的计算属性。然后再通过 kf 调用指定的 API，这是在 Swift 中写 Extension 时很流行的写法。

在 OC 当中，我们在写扩展(分类)的时候，会在扩展方法前面加上一个 `xx_` 样式的前缀，来标明这是一个自定义的扩展。这样做的好处有两个，**第一，避免语言或系统升级更新后，系统 API 与你自定义的扩展重名导致冲突， 第二，使用前缀，当你想要调用扩展方法时，Xcode 的语法提示能替你过滤掉其余选项**。

在 Swift 发布以后，早期还是使用了上述的方法，后来利用 Swift 灵活的协议和泛型系统，这种更为优雅的实现就流行开来，`Kingfisher` 中对 `kf` 的实现很简单，如下可见:

```Swift
/// Wrapper for Kingfisher compatible types. This type provides an extension point for
/// connivence methods in Kingfisher.
public struct KingfisherWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/// Represents an object type that is compatible with Kingfisher. You can use `kf` property to get a
/// value in the namespace of Kingfisher.
public protocol KingfisherCompatible: AnyObject { }

/// Represents a value type that is compatible with Kingfisher. You can use `kf` property to get a
/// value in the namespace of Kingfisher.
public protocol KingfisherCompatibleValue {}

extension KingfisherCompatible {
    /// Gets a namespace holder for Kingfisher compatible types.
    public var kf: KingfisherWrapper<Self> {
        get { return KingfisherWrapper(self) }
        set { }
    }
}

extension KingfisherCompatibleValue {
    /// Gets a namespace holder for Kingfisher compatible types.
    public var kf: KingfisherWrapper<Self> {
        get { return KingfisherWrapper(self) }
        set { }
    }
}

extension KFCrossPlatformImageView: KingfisherCompatible { }
```

我们从一个简单的例子来看 `imageView.kf.setImage(xxxx)`, 可知 `kf` 是一个扩展属性，为了方便各个类型都能调用这个属性，需要一个协议 `KingfisherCompatible` 和 `KingfisherCompatibleValue`（在 Kingfisher 对 class 约定了一个特殊的协议，正常情况下一个也行）, 在这两个协议中我们默认实现了 `kf` 这个计算属性，这样任意的 Object 和 Value 都能够通过遵守协议实现 `kf` 属性。Kingfisher 中的 `extension KFCrossPlatformImageView: KingfisherCompatible { }`, `KFCrossPlatformImageView` 在 iOS 中就是 `UIImageView`，这样我们就能直接调用 `imageView.kf` 。

而获取到的 `kf` 属性，实际上就是一个包含了调用者自己的 Wrapper，看 `KingfisherWrapper` 的定义可知，这个结构体只是将初始化的值保存起来。这样当我们对 `KingfisherWrapper` 编写扩展方法时，就能通过 `base` 属性获取到原本需要使用的值或对象 (`imageView.kf.base == imageView`)。

最重要的就是 Swift 对泛型约束的支持，显然，我们所有的扩展都是针对 `KingfisherWrapper` 这个结构体的，但实际上我们编写的扩展是针对 `KingfisherWrapper` 中的 `Base`, 我们肯定不希望任意有 `kf` 属性的对象都能调用所有的扩展。而编写扩展的时候，我们也需要确定 `Base` 的类型。通过泛型约束我们就能轻松解决上述的问题。

```Swift
extension KingfisherWrapper where Base: UIButton {

    // MARK: Setting Image
     @discardableResult
    public func setImage(
        with source: Source?,
        for state: UIControl.State,
        placeholder: UIImage? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        // ...
    }
}
```

这是 Kingfisher 对 `UIButton` 的一个扩展方法，通过把泛型参数 `Base` 限定为 `UIButton`, 我们在内部实现扩展方法时，`base` 属性会被编译器推断为 `UIButton` 我们就不需要再进行类型判断和转换了。而在使用的这个方法时，我们写出 `button.kf.` 时，Xcode 能通过类型推断只显示此类型能够使用的扩展方法，很完美。

### Kingfisher 中的主要部分

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20201103172051.png)

代码结构

- **General:** 命名空间、错误类型、资源类型等基础类型的定义
- **Image:** 对 Image 的封装，格式转换，解码，GIF解析
- **Networking:** 网络图片的下载
- **Cache:** 图片的缓存
- **Views:** 内置的进度条和动画 View 视图
- **Extensions:** 对 ImageView、Button、WKInterfaceImage等对象的扩展，常调用的 API 就源与此
- **Utility:** 一些帮助方法，字符串的MD5、Runtime、调用栈之类的
- **SwiftUI:** 针对 SwiftUI 进行的扩展

知道了 Kingfisher 的主要结构以后，我们就从最常用的调用开始，一步步深入并研究途中遇到的各种参数和类型。最简单也是最常用的就是为 ImageView 设置一个图片，代码如下：

```Swift
let url = URL(string: "https://example.com/image.png")
imageView.kf.setImage(with: .network(url))
//imageView.kf.setImage(with: url) 这个方法在内部，会转换为上述形式，上述方法是最终执行的方法
```

此方法定义在 `ImageView+Kingfisher.swift` 当中，我们先来看它的定义：

```Swift
@discardableResult
    public func setImage(
        with source: Source?,
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {            
            // ....            
        }
```

首先，我们解决最简单的 `progressBlock` 和 `completionHandler`， `DownloadProgressBlock` 的定义为 `((_ receivedSize: Int64, _ totalSize: Int64) -> Void)`, 只是一个图片下载进度的回调，然后 `completionHandler` 是图片下载完成的回调，Result 如果是 success 将返回一个 `RetrieveImageResult`，这是一个结构体，里面有一个 `image` 属性可以获取图片，如果失败就返回 `KingfisherError` 类型的错误信息。

其次是 `placeholder`， 它不单单是一个占位图，此处的 `Placeholder` 是一个协议，任何遵守协议的对象都可以作为占位传入，它的定义如下:

```Swift
public protocol Placeholder {    
    /// How the placeholder should be added to a given image view.
    func add(to imageView: KFCrossPlatformImageView)    
    /// How the placeholder should be removed from a given image view.
    func remove(from imageView: KFCrossPlatformImageView)
}
```

这地方体现了面向协议编程的精髓，你无须去创造一个类型，而是描述你所需要的类型的行为，为了减轻实现的难度，这会迫使你尽可能的简化非必要的行为，最后留下的就是纯粹的定义，越是简单就越是灵活，bug 也会更少。就如同数学和物理中的公理一样，越是简单越是稳固，这样上层构建的软件才更加牢固， 此处的这个协议就精准的描述了一个 **Placeholder** 需要实现的所有行为，如何被添加，如何被删除。

然后是 `source`, 此参数顾名思义是提供图片的来源， 查看 `Source` 的实现：

```Swift
public enum Source {
    case network(Resource)
    case provider(ImageDataProvider)

    public var cacheKey: String {
        // ...
    }

    public var url: URL? {
        // ...
    }
}
```

可以看到 `Source` 是一个 Enum, 它有两个类型，一个是`.network(Resource)` 代表网络资源，而 `.provider(ImageDataProvider)` 则表示任何能够提供图片的方式，比如本地图片加载，或是通过编码字符串(base64)获取等。

我们先来看 `.network(Resource)`, 这里说一下在最上面的的例子中,我们常用的是 `imageView.kf.setImage(with: url)`， 它的实现是这样的:

```Swift
    @discardableResult
    public func setImage(
        with resource: Resource?,
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        return setImage(
            with: resource?.convertToSource(),
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler)
    }
```

可以发现我们传入的 `Resource` 会通过 `resource?.convertToSource()` 转换为 `Source` 类型, 实际的调用还是我们上面分析的那个方法

```Swift
public protocol Resource {    
    /// The key used in cache.
    var cacheKey: String { get }    
    /// The target image URL.
    var downloadURL: URL { get }
}

extension Resource {
    public func convertToSource() -> Source {
        return downloadURL.isFileURL ?
            .provider(LocalFileImageDataProvider(fileURL: downloadURL, cacheKey: cacheKey)) :
            .network(self)
    }
}

extension URL: Resource {
    public var cacheKey: String { return absoluteString }
    public var downloadURL: URL { return self }
}
```

以上是 `Resource` 的定义，一个远程资源需要有下载地址 `downloadURL` 和缓存 key `cacheKey` , 我们能直接传入 URL 类型是因为 URL 遵守了 `Resource`  的协议。
现在可以看出 `imageView.kf.setImage(with: url)` 内部会被转换为 `imageView.kf.setImage(with: .network(url))`. `Resource` 作为一个协议能更方便扩展其他类型的数据作为资源来使用，这在实际项目当中很有用，我们能直接扩展项目中的 Model 作为 `Resource` 传入。

接下来看 Source 的另一个值 `.provider(ImageDataProvider)`, `ImageDataProvider` 的定义如下:

```Swift
public protocol ImageDataProvider {
    var cacheKey: String { get }
    func data(handler: @escaping (Result<Data, Error>) -> Void)
    var contentURL: URL? { get }
}
```

`ImageDataProvider` 中主要约定了一个资源的缓存 key，和一个获取图片数据的方法, 在我们上面的例子中，当传入的 url 地址是本地地址时，会被转换为 `LocalFileImageDataProvider`, 这是一个本地图片的 ImageDataProvider 的实现，主要实现如下:

```Swift
public struct LocalFileImageDataProvider: ImageDataProvider {
    public let fileURL: URL
    public init(fileURL: URL, cacheKey: String? = nil) {
        self.fileURL = fileURL
        self.cacheKey = cacheKey ?? fileURL.absoluteString
    }

    public var cacheKey: String

    public func data(handler: (Result<Data, Error>) -> Void) {
        handler(Result(catching: { try Data(contentsOf: fileURL) }))
    }

    public var contentURL: URL? {
        return fileURL
    }
}
```

本地图片的路径被作为 Cache Key， 图片的获取方法，就是加载本地图片文件的数据，这就是本地图片的 Provider 实现。

最后我们来看参数 `options`， 他的类型定义是 `public typealias KingfisherOptionsInfo = [KingfisherOptionsInfoItem]`, options 中包含了图片加载的动画，动画样式，缓存管理，执行线程等等各种设置, `KingfisherOptionsInfoItem` 是一个枚举，里面列举了各种各样的设置参数，最后这个包含设置的数组会被转换为 `KingfisherParsedOptionsInfo` 这是一个结构体，属性就是 `KingfisherOptionsInfoItem` 所有的枚举值. 这里面的设置参数控制了很多的东西，继续往里分析，等遇到的时候，我们再来关注他们的作用.

返回值 `DownloadTask` 是一个下载任务，可以用来取消下载任务，暂且不细看它了。

接下来我们仔细研究一下此方法的实现，里面应该包含了 ImageView 加载图片的过程。因为实现很长，我们分段解析，开头如下：

```Swift
var mutatingSelf = self
guard let source = source else {
    mutatingSelf.placeholder = placeholder
    mutatingSelf.taskIdentifier = nil
    completionHandler?(.failure(KingfisherError.imageSettingError(reason: .emptySource)))
    return nil
}        
```

这段代码主要是对 `source`  的值进行判空，如果值为 nil 就直接返回错误，并设置一些属性。

第一行就值得分析一下,此处的 `self` 的类型就是 `KingfisherWrapper`， 我们知道结构体内的方法改变属性需要使用 `mutating` 标记。而此处作者使用 `var mutatingSelf = self` 来复制一个 mutating value. *为什么不是将方法标记为 `mutating` 然后直接修改属性呢？* 稍作思考，我们应该知道改变一个结构体的属性，除了方法需要标记为 `mutating` 以外，这个结构体也需要是可变的(mutating value), 而我们通过 `imageView.kt` 只读属性拿到的是一个 `immutable value`，即使将方法标记为 `mutating` 也无法调用，会报 `error: cannot use mutating member on immutable value: 'kt' is a get-only property` 的错误。

不过这里的 `mutatingSelf` 作为值类型是复制的，*我们对复制的 mutatingSelf 进行属性修改，并不会修改原来 self 中的值啊？* 这里我们需要看一下赋值的属性是如何定义的:

```Swift
public private(set) var taskIdentifier: Source.Identifier.Value? {
    get {
        let box: Box<Source.Identifier.Value>? = getAssociatedObject(base, &taskIdentifierKey)
        return box?.value
    }
    set {
        let box = newValue.map { Box($0) }
        setRetainedAssociatedObject(base, &taskIdentifierKey, box)
    }
}
```

`taskIdentifier` 是对 `KingfisherWrapper` 扩展的计算属性，而它的本质是对内部的 base 进行赋值操作, 使用 `Runtime` 机制我们可以动态的为对象添加属性和方法，这里就不在展开，使用 `Box` 来包装值，只是为了将值类型包装为对象方便进行存储。 

看到这里我们发现，对 mutaingSelf 的复制操作，本质上是在操作内部的 base 对象，而 base 的类型是 `KFCrossPlatformImageView` 这是一个引用类型, 值类型复制时，并不会拷贝内部的引用属性，mutatingSelf 中的 base 和 self 中的 base 还是同一个对象。那上述代码实际上都是对同一个 base 进行赋值操作, 所以这样写是没有问题的。



## 封装为 SwiftUI 中的 View

