---
title: Observe App's Lifecycle in SwiftUI
date: 2021-04-08 15:01:55
tags:
- MacOS
marks:
- SwiftUI:green
---

Recently, I'm writing a pure SwiftUI MacOS application. But I found that there's no an app delegate in the App struct type. Sometimes we need to observe the lifecycle of the application. The SwiftUI provides two ways that we can observe the app's lifecycle.

- **Environment scenePhase**
- **The wrapped value NSApplicationDelegateAdaptor**

```Swift
// ClassSchedulerApp.swift
@main
struct ClassSchedulerApp: App {

    @Environment(\.scenePhase) private var scenePhase
    @NSApplicationDelegateAdaptor(AppDelegator.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()            
        }
        .onChange(of: scenePhase) { phase in
            print(phase)
        }
    }
}
```

```Swift
// AppDelegator.swift
class AppDelegator: NSObject, NSApplicationDelegate {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("applicationWillFinishLaunching")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("applicationDidFinishLaunching")
    }
}

```

### Environment scenePhase
first, you should declare a Environment property scenePhase. And then, use the function `onChange` to observer it. When the app is closed or minimized, the phase will be `inactive`. If the app come back to foreground, the phase will be `active`. You can look at the ScenePhase's values in the [Apple's documents](https://developer.apple.com/documentation/swiftui/scenephase).

### @NSApplicationDelegateAdaptor

The wrappedValue `@NSApplicationDelegateAdaptor` gives us a familiar way to observe the app's lifecycle that to implement a class AppDelegator abiding by the protocol `NSApplicationDelegate`. In the class AppDelegator, you can do anything you want just like in the `UIKit` or `AppKit`.
