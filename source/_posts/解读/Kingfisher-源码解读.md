---
title: Kingfisher 源码解读
date: 2020-11-03 14:29:22
tags:
- iOS
- Swift
- SwiftUI
categories:
- 源码解读
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

继续往下看:

```Swift
var options = KingfisherParsedOptionsInfo(KingfisherManager.shared.defaultOptions + (options ?? .empty))
let isEmptyImage = base.image == nil && self.placeholder == nil
if !options.keepCurrentImageWhileLoading || isEmptyImage {
    // Always set placeholder while there is no image/placeholder yet.
    mutatingSelf.placeholder = placeholder
}
```

第一行通过配置参数生成了配置信息，这里出现的 `KingfisherManager` 是一个管理类，里面包含了对默认配置参数，图片下载器，缓存相关的配置，这里先记住它的大致作用就行了。后续的代码，是根据配置信息设置 `placeholder` 的值。

```Swift
let maybeIndicator = indicator
maybeIndicator?.startAnimatingView()
```

这里打开图片的加载动画，`indicator` 也是一个扩展属性，它同样是通过 `runtime`  存储在 base(imageView) 当中的。他的类型 `Indicator` 是一个协议，约定了指示器的行为，具体可以查看定义。

继续看:

```Swift
let issuedIdentifier = Source.Identifier.next()
mutatingSelf.taskIdentifier = issuedIdentifier

if base.shouldPreloadAllAnimation() {
    options.preloadAllAnimationData = true
}
```

我们在看 Source 的时候，忽略了内部定义的 `Identifier`， 我们查看的它的定义：

```Swift
public enum Identifier {

    /// The underlying value type of source identifier.
    public typealias Value = UInt
    static var current: Value = 0
    static func next() -> Value {
        current += 1
        return current
    }
}
```

它其实就是一个迭代器， 在 App 的声明周期内用来生成自增的 UInt 数值，不重复的数值用来表示当前加载图片的任务 ID，我猜测后续的进度和状态通知会用到这个 ID。接下来是设置了一个 `preloadAllAnimationData` 的属性，应该是动画相关的处理，后续再看。

然后就是进度和状态相关的回调设置了，代码如下:

```Swift

if let block = progressBlock {
    options.onDataReceived = (options.onDataReceived ?? []) + [ImageLoadingProgressSideEffect(block)]
    }

if let provider = ImageProgressiveProvider(options, refresh: { image in
    self.base.image = image
}) {
    options.onDataReceived = (options.onDataReceived ?? []) + [provider]
}
        
options.onDataReceived?.forEach {
    $0.onShouldApply = { issuedIdentifier == self.taskIdentifier }
}
```

根据字面意思，开头的 `block` 应该是进度监听的，`provider` 是图片加载的回调 （并不是图片下载完后设置图片，而是图片下载过程中，显示部分图片，图片数据不全时也可以先显示已有数据的图片，有很多的加载方法，有如从上往下逐行扫描加载，也有分隔显示数据，在逐步填充等等）。重点关注 `onDataReceived` ，点进去可以看到它的定义是 `var onDataReceived: [DataReceivingSideEffect]? = nil`, 它用来存储接收到图片数据时，会触发的各种"副作用"，这里的副作用是指用与图片下载事务本身无关，只是为了满足外界的状态处理，进而在获取到图片数据时，通知所有的监听者。我们来看看 `DataReceivingSideEffect` 是如何定义的：

```Swift
protocol DataReceivingSideEffect: AnyObject {
    var onShouldApply: () -> Bool { get set }
    func onDataReceived(_ session: URLSession, task: SessionDataTask, data: Data)
}
```

定义很简单，`onShouldApply` 说明此条副作用是否还有效，为什么定义为 `block`，我们后续再看。`onDataReceived` 就是每次获取到最新的 data 时的调用了。我们再来看最后一句:

```Swift
options.onDataReceived?.forEach {
    $0.onShouldApply = { issuedIdentifier == self.taskIdentifier }
}
```

 循环设置了 onDataReceived 的 onShouldApply 属性，在上面的分析中，我们知道每次执行新的任务都会生成一个新的 taskIdentifier, 这个 id 实际是设置到了 imageView 的扩展属性中去了， 到这里就能明白为什么使用 block 而不是普通的值了， 每次调用 block 都是和 imageView 当前的 taskIdentifier 进行对比，比如一个 imageView 短时间重复设置加载图片，只有最后一个加载任务的进度和数据信息会被传递出去，防止多个加载任务之间的信息错乱。

上述都是进行相关的设置，接下就是图片的下载部分了，代码比较长，我直接在代码中标注相关的意思。

```Swift
// 下面会开始分析 KingfisherManager，这里分析整个加载的过程
let task = KingfisherManager.shared.retrieveImage(
    with: source,
    options: options,
    downloadTaskUpdated: { mutatingSelf.imageTask = $0 },
    completionHandler: { result in
    // 图片下载完成的回调
        CallbackQueue.mainCurrentOrAsync.execute {
            // CallbackQueue 是作者定义的枚举，内部就是根据不同的场景分别开辟不同的线程
            maybeIndicator?.stopAnimatingView() // 关闭指示器
            // 这里首先进行了 taskIdentifier 的判断，如果 imageView 没有 id 的话，证明没有任务或是任务已经完成
            guard issuedIdentifier == self.taskIdentifier else {
                // 如果没有 id 就返回错误信息
                let reason: KingfisherError.ImageSettingErrorReason
                do {
                    let value = try result.get()
                    reason = .notCurrentSourceTask(result: value, error: nil, source: source)
                } catch {
                    reason = .notCurrentSourceTask(result: nil, error: error, source: source)
                }
                let error = KingfisherError.imageSettingError(reason: reason)
                completionHandler?(.failure(error))
                return
            }
            
            // 这里在任务结束后，把 task 和 id 置空，所有的状态传递和回调都依赖于对 id 的判断，置空后就能确保不发生异常的状态传递
            mutatingSelf.imageTask = nil
            mutatingSelf.taskIdentifier = nil
            
            switch result {
            case .success(let value):
                // 成功后，这里判断是否有过渡动画，不需要就设置图片并返回结果
                guard self.needsTransition(options: options, cacheType: value.cacheType) else {
                    mutatingSelf.placeholder = nil
                    self.base.image = value.image
                    completionHandler?(result)
                    return
                }
                
                // 显示过渡动画
                self.makeTransition(image: value.image, transition: options.transition) {
                    completionHandler?(result)
                }
                
            case .failure:
            // 下载图片失败后，如果配置中有失败图片的配置，显示错误图片
                if let image = options.onFailureImage {
                    self.base.image = image
                }
                completionHandler?(result)
            }
        }
    }
)
mutatingSelf.imageTask = task
// 最后返回生成的下载任务
return task
```

以上我们逐行分析了 `imageView.kf.setImage(with: url)` 中，图片下载和设置的流程。现在大致对整个流程有了了解，接下来我们逐个分析其中使用的模块，首先我们从 `KingfisherManager` 入手，它整合了 Kingfisher 中的各个模块。

## KingfisherManager 

在上面的例子中，我们核心是调用 KingfisherManager  中 `retrievingImage` 方法来加载图片的，我们就从这里开始入口，逐行了解相关的作用:

在分析代码之前，我是有一个疑问的，downloadTaskUpdated 用来更新 task 是为什么，调用 retrievingImage 时返回的 task 会发生变化吗？

```Swift
func retrieveImage(
    with source: Source,
    options: KingfisherParsedOptionsInfo,
    downloadTaskUpdated: DownloadTaskUpdatedBlock? = nil,
    completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask?
{
    // RetrievingContext 是我们加载图片的上下文，可以查看下面的解析, 在回过头来继续往下看
    let retrievingContext = RetrievingContext(options: options, originalSource: source)
    // 重试上下文，主要记录重试的次数，和上次重试用户留下的信息
    var retryContext: RetryContext?
    
    // 启动一个新的检索任务
    // 这里的 `retrievingImage` 是更具体的实现，后面我们再看，这里也是更新 task 的地方，
    // 根据 `RetrievingContext` 中的代码，可以猜测是在加载失败时，进行备用资源的替换，所有 task 也会进行更新，
    // 这里也就能理解我的疑问，为什么中途需要进行 task 的更新操作了
    func startNewRetrieveTask(
        with source: Source,
        downloadTaskUpdated: DownloadTaskUpdatedBlock?
    ) {
        let newTask = self.retrieveImage(with: source, context: retrievingContext) { result in                
            handler(currentSource: source, result: result)
        }
        downloadTaskUpdated?(newTask)
    }

    // 加载失败时候的处理    
    func failCurrentSource(_ source: Source, with error: KingfisherError) {
        // 如果用户主动取消了任务，就直接返回失败
        // Skip alternative sources if the user cancelled it.
        guard !error.isTaskCancelled else {
            completionHandler?(.failure(error))
            return
        }
        // 如果有替代资源，就开启一个新的任务下载替代资源
        if let nextSource = retrievingContext.popAlternativeSource() {
            startNewRetrieveTask(with: nextSource, downloadTaskUpdated: downloadTaskUpdated)
        } else {
            // 如果没有替换资源，就返回错误
            // 如果在前面的过程中没有产生过其他的错误，就返回当前错误，如果有的话，会把错误数组重新包装一下返回
            // No other alternative source. Finish with error.
            if retrievingContext.propagationErrors.isEmpty {
                completionHandler?(.failure(error))
            } else {
                retrievingContext.appendError(error, to: source)
                let finalError = KingfisherError.imageSettingError(
                    reason: .alternativeSourcesExhausted(retrievingContext.propagationErrors)
                )
                completionHandler?(.failure(finalError))
            }
        }
    }
    // 对结果的处理
    func handler(currentSource: Source, result: (Result<RetrieveImageResult, KingfisherError>)) -> Void {
        switch result {
        case .success:
        // 成功直接返回结果
            completionHandler?(result)
        case .failure(let error):
        // 这里读取配置中的重试策略, 如果不为空，会根据配置进行重试
            if let retryStrategy = options.retryStrategy {
                let context = retryContext?.increaseRetryCount() ?? RetryContext(source: source, error: error)
                retryContext = context
                
                // 这里的 retryStrategy 是一个协议，只有一个 `retry` 方法，你来实现想要的重试策略
                retryStrategy.retry(context: context) { decision in
                    switch decision {
                    case .retry(let userInfo):
                        retryContext?.userInfo = userInfo
                        // 重试就再次发送请求
                        startNewRetrieveTask(with: source, downloadTaskUpdated: downloadTaskUpdated)
                    case .stop:
                    // 提交失败
                        failCurrentSource(currentSource, with: error)
                    }
                }
            } else {
                // 在不进行重试的情况下，这里的操作其实和 `failCurrentSource` 中的基本一模一样
                // Skip alternative sources if the user cancelled it.
                guard !error.isTaskCancelled else {
                    completionHandler?(.failure(error))
                    return
                }
                if let nextSource = retrievingContext.popAlternativeSource() {
                    // 唯独这里相比 `failCurrentSource` 多了一行记录错误信息的代码
                    retrievingContext.appendError(error, to: currentSource)
                    startNewRetrieveTask(with: nextSource, downloadTaskUpdated: downloadTaskUpdated)
                } else {
                    // No other alternative source. Finish with error.
                    if retrievingContext.propagationErrors.isEmpty {
                        completionHandler?(.failure(error))
                    } else {
                        retrievingContext.appendError(error, to: currentSource)
                        let finalError = KingfisherError.imageSettingError(
                            reason: .alternativeSourcesExhausted(retrievingContext.propagationErrors)
                        )
                        completionHandler?(.failure(finalError))
                    }
                }
            }
        }
    }
    // 这里是调用更加深乘次的获取资源的方法
    return retrieveImage(
        with: source,
        context: retrievingContext)
    {
        result in
        handler(currentSource: source, result: result)
    }
}
```

在以上的方法中，我们基本上已经清楚了检索图片时，成功后的处理，失败及失败后的重试操作，还有替代资源的加载。

### RetrievingContext

```Swift
// 整个加载图片的上下文
class RetrievingContext {
    // 设置信息
    var options: KingfisherParsedOptionsInfo
    // 原始 Source
    let originalSource: Source
    // 在图片加载过程中，各个环境产生的错误
    var propagationErrors: [PropagationError] = []

    init(options: KingfisherParsedOptionsInfo, originalSource: Source) {
        self.originalSource = originalSource
        self.options = options
    }

    // 获取可替代的资源
    func popAlternativeSource() -> Source? {
        // 用户可以设置替代资源，在原 source 获取失败的情况下，会依次加载替代资源
        guard var alternativeSources = options.alternativeSources, !alternativeSources.isEmpty else {
            return nil
        }
        let nextSource = alternativeSources.removeFirst()
        options.alternativeSources = alternativeSources
        return nextSource
    }

    // 记录新的错误
    @discardableResult
    func appendError(_ error: KingfisherError, to source: Source) -> [PropagationError] {
        let item = PropagationError(source: source, error: error)
        propagationErrors.append(item)
        return propagationErrors
    }
}
```

顺着上面的代码继续往下，最后调用的 `retrieveImage` 的定义是这样的：

```Swift
private func retrieveImage(
    with source: Source,
    context: RetrievingContext,
    completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask?
{
    let options = context.options
    if options.forceRefresh {
        return loadAndCacheImage(
            source: source,
            context: context,
            completionHandler: completionHandler)?.value
        
    } else {
        let loadedFromCache = retrieveImageFromCache(
            source: source,
            context: context,
            completionHandler: completionHandler)
        
        if loadedFromCache {
            return nil
        }
        
        if options.onlyFromCache {
            let error = KingfisherError.cacheError(reason: .imageNotExisting(key: source.cacheKey))
            completionHandler?(.failure(error))
            return nil
        }
        
        return loadAndCacheImage(
            source: source,
            context: context,
            completionHandler: completionHandler)?.value
    }
}
```

上面的代码的逻辑很清晰，就是根据配置，看是获取图片还是读取缓存。这里的两个核心方法，一个是获取图片 `loadAndCacheImage`， 另一个是 `retrieveImageFromCache`, 我们先从 loadAndCacheImage 入手，看看如何加载图片的：

### loadAndCacheImage 加载图片并缓存

```Swift
// 定义上的意思是加载图片并缓存
@discardableResult
func  loadAndCacheImage(
    source: Source,
    context: RetrievingContext,
    completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask.WrappedTask?
{
    // 这里是一个缓存图片的方法
    let options = context.options
    func _cacheImage(_ result: Result<ImageLoadingResult, KingfisherError>) {
        cacheImage(
            source: source,
            options: options,
            context: context,
            result: result,
            completionHandler: completionHandler
        )
    }
    
    switch source {
    case .network(let resource):
    // 如果是网络图片，就通过 downloader 进行下载，这个 downloader 我们后续肯定会再进行详细分析
        let downloader = options.downloader ?? self.downloader
        let task = downloader.downloadImage(
            with: resource.downloadURL, options: options, completionHandler: _cacheImage
        )

        if let task = task {
            return .download(task)
        } else {
            return nil
        }
        
        // 通过 provider 获取图片数据,
    case .provider(let provider):
        provideImage(provider: provider, options: options, completionHandler: _cacheImage)
        return .dataProviding
    }
}
```

我们先挑简单的来， 通过 provider 获取 image 内部的代码是很简单了，`ImageDataProvider`  这个协议上面我们讲到过，内部通过 `data(handler: @escaping (Result<Data, Error>) -> Void)`  方法来获取图片，除了我们自定义以外，本地图片的获取方法就是加载本地地址而已，就不多做赘述了。

#### 