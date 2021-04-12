---
title: How to do animation when you use Redux in SwiftUI
date: 2021-04-12 17:13:52
tags:
- SwiftUI
marks:
- SwiftUI:green
---


I'm writing a macOS application using Redux in SwiftUI. In the Redux, I declared an EnvironmentObject `Store`, a struct AppState and an enum AppAction. The AppState is a Published property in the Store. When we dispatch an AppAction to the Store, it will generate a new AppState through the old AppState and the Action. The AppState is the data source of all the pages. All the UI is rendered by AppState. It's more simple and powerful than using MVC or MVVM in SwiftUI.

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210412183444.png)

But, there are some questions about the animation. Modifying the AppState, we want to do an animation for the changed UI. If we use the implicit animation, all the views might get animation although some we don't want. 

How about the explicit animation?  The explicit animation has the same questions as the implicit animation. If you want to get the correct animation, you must reduce the impact area of the state's changes. 

So we can set a @State animation property in the special view to control it's animation, and then use the explicit animation to change it. But how can we observe the AppState's changes to modify the animation property? The SwiftUI provides a function `onReceive` to observe a publisher. Be lucky, the AppState is a Publish property of the ObservedObject Store. We can use the `store.$appState` to get the publisher and work with the `map` to get the value we want.

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210412183246.png)

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210412183407.png)