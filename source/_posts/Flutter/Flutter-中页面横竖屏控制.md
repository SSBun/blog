---
title: Flutter/flutter_boost 中页面横竖屏控制
date: 2020-11-12 15:33:47
tags:
categories:
- Flutter
---

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20201116115103.png)

最近项目中越来越多的页面开始使用 Flutter 进行开发，这时一个棘手的问题就暴露出来，我们项目中对 Flutter 页面横竖屏的控制非常的僵硬，基本上就是在被跳转的页面的 init 方法中进行了横竖屏的设置，然后在 dispose 的时候再改回去，当初这样写的原因在于任务紧张并且团队初次使用了 Flutter 来开发，对 Flutter 中的各种机制还不是特别的了解，并且就几个页面，跳转的逻辑十分的简单，就将就了一下。

现在页面多了，这样写的缺点就很大了。严重依赖页面间的跳转顺序，一切的横竖屏设置都是依赖于固定路径的跳转，否者在 dispose 的时候就无法设置正确的屏幕方向，在 Flutter 中最理想的是使用 route 来进行任意的跳转，我们这种写法对此而言简直就是灾难。

## 实现方案

正好最近有时间就研究了一下这个问题，并找到了一个相对可靠的解决方案，根据我的经验，我想实现一种类似于 iOS 当中横竖屏控制的机制。在 iOS 当中，每个 ViewController 都能重写三个只读属性，来设置自己的屏幕方向。这样每个页面只需要声明自己的屏幕方向，就能在显示自身时获得正确的显示，无须关心导航栈中的其他页面，屏幕方向的控制都交给 Navigator 来管理。

### 监听导航栈

要实现上述功能，最重要的一点就是，我们要监听导航栈的变动，在 Flutter 中，当我们 push 一个页面和 pop 一个页面的时候，我们需要监听到两个数据，一个是 push 时要去的页面，一个是 pop 时所要返回的页面。这样我们就能通过读取页面的配置信息来修改屏幕方向，实现类似的效果。

在 Flutter 中我们创建一个 `MaterialApp` 时，有一个属性是 `final List<NavigatorObserver> navigatorObservers;`， 其中的 `NavigatorObserver` 是一个类，里面定义了两个重要的方法 `void didPush(Route<dynamic> route, Route<dynamic> previousRoute) { }` 和 `void didPop(Route<dynamic> route, Route<dynamic> previousRoute) { }`。当 Flutter 页面中的导航栈发生变化时，会通知所有的 navigatorObservers，并调用上面的两个方法。

这里我们需要实现一个自己的 navigatorObserver 来监听导航栈，这里我们定义一个:

```Dart
class OrientationNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route previousRoute) {
    debugPrint(
        'didPush route: $route previousRoute: $previousRoute');
  }

  @override
  void didPop(Route route, Route previousRoute) {
    debugPrint(
        'didPop route: $route previousRoute: $previousRoute');
  }
}
```

将 `OrientationNavigatorObserver` 设置到 navigatorObservers 中以后，我们在两个方法里面都打印出 `route` 和 `previousRoute`，运行项目进行一些跳转，观察打印的信息，这里可能会出现多种情况：

首先，如果你在项目中使用了是这样的跳转方法:

```Dart
Navigator.of(context)
.push(MaterialPageRoute(builder: (context) {
    return VipTaskRegular();
}));
```

直接使用 push 方法进行跳转，打印出的信息中 `settings` 的值会是 (null, null)，而这个 `route`  不会携带和你的 widget （这里是 VipTaskRegular）相关的信息，我们就无法确定跳转的页面，也就无法进行相关的设置，settings 中的两个值，一个是 name（路由）,还有 arguments （携带的参数），所以使用 push 直接进行跳转的页面我们是无能为力的。

其实使用 push 进行页面跳转不是最优方法，在现在的开发模式中，无论是原生应用还是 Flutter 都开始流行使用路由地址来进行页面跳转，就像 web 那样。通过一个确定的 `uri` 我们在任何页面都能跳转到任何页面。Flutter 也是推荐先在 MaterialApp 中的 `routes` 注册路由，然后我们就能通过 `pushNamed(context, routeName)` 直接进行页面跳转，这种方案代码更加简洁，结构上也清晰。

与此同时，我们就能在 `didPush` 和 `didPop`  的 route 中捕获到 `route.settings.name` 。因为路由地址和页面是一一对应的，通过这个 routeName 我们就能知道对应的页面是什么了。

> didPush 中将要显示的页面是 route, 而在 didPop 中将要返回的页面是 previousRoute

### 页面配置

解决了监听的问题，接下来就是如何读取页面的相关设置。最初的想法还是依赖于 iOS 中的机制（方案一）：

1. 我想要定义一个抽象类，里面定义上读取横竖屏方向的静态属性或方法（因为无法获取 widget 实例，实例方法和属性也就无从获取了）
2. 各个页面实现抽象类中的属性和方法，返回配置信息
3. 在导航监听中，通过 routeName 获取才页面的类型，并读取配置
4. 通过配置信息设置横竖屏方向

但是，上面的设想中，第一条就无法实现，Dart 中的静态方法是无法向下传递给子类的，所以无论是 extends 还是 implements,都是无效的。其次，存储页面的 Type 类型到 Map 中，再读取出来时，也只能通过 switch 进行类型判断。这都是因为我们无法实现一个可以定义静态属性和方法的抽象类。因为无法获取到 widget 的实例，我们也无法像 iOS 那样，通过读取实例的属性来获取配置信息。

既然上面的行不通，其次也实现不了像 iOS 那样的效果，毕竟如果读取不到实例，也就无法在运行时让实例通过属性来自由控制屏幕的方向，我们就索性设置一个配置表，通过 routeName 和 config 的对应，我们读取预设值进行相关的设置。这样我们就只需要在一个集中的地方，统一注册相关的设置就 ok 了

> 通过配置表统一设置，和通过实现协议各自配置，孰优孰劣就见仁见智了，iOS 中更推崇自己的事情自己干。

这里我直接把相关的代码粘贴上来:

```Dart
// Flutter page orientation config.
abstract class OrientationSupport {
  bool get available;
  List<DeviceOrientation> get preferredOrientations;
  List<SystemUiOverlay> get overlays;
}

// Default horizontal config.
class OrientationSupportHorizontal implements OrientationSupport {
  @override
  bool get available => true;
  @override
  List<DeviceOrientation> get preferredOrientations => Platform.isIOS
      ? [DeviceOrientation.landscapeRight]
      : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];

  @override
  List<SystemUiOverlay> get overlays =>
      [SystemUiOverlay.top, SystemUiOverlay.bottom];
}

// Default vertical config.
class OrientationSupportVertical implements OrientationSupport {
  @override
  bool get available => true;
  @override
  List<DeviceOrientation> get preferredOrientations =>
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];

  @override
  List<SystemUiOverlay> get overlays => [];
}

class OrientationSupportStay implements OrientationSupport {
  @override
  bool get available => false;
  @override
  List<DeviceOrientation> get preferredOrientations => [];
  @override
  List<SystemUiOverlay> get overlays => [];
}

OrientationSupportVertical _vertical() => OrientationSupportVertical();

class OrientationSupportManager {
  static Map<String, OrientationSupport> _list = {
    WordMainPage.name: _vertical(),
  };

  // Leo default page orientation is horizontal.
  static OrientationSupport get defaultOrientationSupport =>
      OrientationSupportHorizontal();

  static void register(String route, OrientationSupport orientationSupport) =>
      _list[route] = orientationSupport;

  static void registerVertical(String route) =>
      register(route, OrientationSupportVertical());

  static OrientationSupport retrieve(String route) => _list[route];
}

```

`OrientationSupport` 是配置类，里面定义了屏幕方向和状态栏等显示状态，这些都是在屏幕转换时需要改变的设定。下面就分别定义了横屏和竖屏的常用配置，和一个不触发任何转屏操作的类（它的作用主要是给那些横竖屏都兼容的页面使用的，比如弹窗）`OrientationSupportManager` 中用来注册各自页面的横竖屏设置。

为了方便使用，在我们的项目中，因为大部分的屏幕是横屏的，所以我会设定一个 `defaultOrientationSupport` 为横屏，这样在后续处理的时候，我就只用注册竖屏的界面，而不用把所有的页面都设置一遍。

接下来的操作就是在 `NavigatorObserver` 中根据监听来修改屏幕的方向了，代码如下：

```Dart
class OrientationNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route previousRoute) {
    debugPrint('didPush route: $route previousRoute: $previousRoute');
    _setupOrientation(route.settings.name);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    debugPrint('didPop route: $route previousRoute: $previousRoute');
    _setupOrientation(previousRoute.settings.name);
  }

  void _setupOrientation(String route) {
    // assert(route != null, 'The page have not register route');
    if (route != null) {
      var orientationSupport = OrientationSupportManager.retrieve(route);
      orientationSupport ??=
          OrientationSupportManager.defaultOrientationSupport;
      if (!orientationSupport.available) return;
      // assert(orientationSupport != null,
      // '$route have not register orientation support');
      SystemChrome.setPreferredOrientations(
          orientationSupport.preferredOrientations);
      SystemChrome.setEnabledSystemUIOverlays(orientationSupport.overlays);
    }
  }
}
```

如果路由为空的话，就不做任何响应，正常的情况下任何页面的跳转都必须通过 pushNamed 来进行，这样的 routeName 是不会为空的。不过也不排除像 alert 弹窗这样的页面，在 Flutter 中也是用 push 显示，但是因为没有特殊的意义且生命周期短暂就没有用 pushNamed 来跳转的事例。然后就是通过 routeName 进行检索，拿到配置，如果没有获取到，就使用默认配置。最后通过 `SystemChrome` 来设置屏幕方向。

## flutter_boost 中如何使用

我们的项目属于原生中嵌入 Flutter 页面，在处理 Native 和 Flutter 的导航关系时，使用了 [alibaba/flutter_boost](https://github.com/alibaba/flutter_boost)。这里也分为两个场景的使用: 

### 场景一: flutter 内部跳转也使用 flutter_boost

在 Flutter 内部的跳转也使用了 `flutter_boost` 来进行处理的话，通过设置 MaterialApp 的 `navigatorObservers` 是没有用的，所有的导航跳转都被 flutter_boost 接管了，我们需要通过 `FlutterBoost.singleton.addContainerObserver(BoostContainerObserver observer)` 进行监听设置。 BoostContainerObserver 就是一个 block 函数，它提供的信息和原来的 NavigatorObserver 差不多。

```Dart
typedef BoostContainerObserver = void Function(
    ContainerOperation operation, BoostContainerSettings settings);

enum ContainerOperation { Push, Onstage, Pop, Remove }

class BoostContainerSettings {
  const BoostContainerSettings({
    this.uniqueId = 'default',
    this.name = 'default',
    this.params,
    this.builder,
  });

  final String uniqueId;
  final String name;
  final Map<String, dynamic> params;
  final WidgetBuilder builder;
}
```

和原来的方法一样，我们需要监听的是 `Push` 和 `Pop` 操作，而 settings 里的 `name` 就是 rotueName。

### 场景二: flutter 内部跳转不使用 flutter_boost

还有一种情况就是，在 flutter -> native 和 native -> flutter 中使用 flutter_boost。但是在 flutter -> flutter 时，还是使用 flutter 内部的 `push` 方法进行跳转。

在这种情况下，我们使用 `FlutterBoost.singleton.addBoostNavigatorObserver` 来添加一个 `NavigatorObserver`, 然后在项目中运行，flutter 内部相互之间的跳转是没有问题的，但是当你从 native 跳转到 flutter 页面的时候，你会发现进入的 flutter 页面横竖屏设置没有生效，但是再后续的 flutter 内部的跳转，横竖屏的设置是生效的。

进一步研究，我们发现从 native A 跳转 flutter B 的时候，无论这个 B 页面的 routeName 在 `flutter_boost` 和 `MaterialApp` 中的注册路由为何值，在我们的监听中，routeName 都会变为 `/`。这就导致对 B 页面的横竖屏设置失效了。要解决这个问题，我们就需要同时监听 `FlutterBoost.singleton.addContainerObserver`。

当从 native -> flutter 的时候，在 `Push` 方法中，我们能监听到 B 页面正确的 routeName。这里我们就能读取到相对应的配置信息，然后把配置信息更新到配置表中，key 不是 routeName 而是 `/`。通过覆盖 `/` 的默认配置，我们就能修复这个问题。在 `OrientationNavigatorObserver` 添加这个监听:

> NavigatorObserver 的调用时机晚于 ContainerObserver

```Dart
static void flutterContainerObserver(
      ContainerOperation operation, BoostContainerSettings settings) {
    debugPrint(
        'operation: $operation, settings: name -> ${settings.name} params -> ${settings.params}');
    if (operation == ContainerOperation.Push) {
      var routeName = settings.name;
      OrientationSupport orientationSupport =
          OrientationSupportManager.retrieve(routeName) ?? OrientationSupportManager.defaultOrientationSupport;
      OrientationSupportManager.register('/', orientationSupport);
    }
  }
```

## 总结

通过使用集中的配置将横竖屏的设置代码从各个页面中抽离出来，各个页面无感知的实现了页面横竖屏的设定。因为依赖使用 `pushNamed` 来进行页面跳转，也使得团队的代码风格更加统一，所有的页面都能通过 routeName 来进行跳转，方便了以后的开发和维护。现阶段的局限是，因为无法获取到页面实例，也就无法通过页面实例内部的属性，来动态的调整横竖屏。不过因为配置项是一个接口，通过自定义某个页面的特殊配置类，然后再在页面中修改这个配置类的静态属性的话，应该也能实现动态的修改，不过这样的场景较为少见。
