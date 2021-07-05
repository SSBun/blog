---
title: iOS 导航栏的控制
date: 2017-8-22 15:36:54
tags:
- Animation
categories:
- iOS
---

## 颜色
导航条的属性 `translucent` 可以控制导航条是否是透明的， 默认是 YES，也就是透明的。打开时透过导航条可以模糊的看到 ViewController 或是 Window 的背景图案。这里我们分为两种情况来讨论背景颜色的设置

在关闭 `translucent` 的情况下
可以通过 `barTintColor` 来设置导航条的背景色
当然也可以通过 `setBackgroundImage` 来设置背景
但是 `backgroundImage` 的图层更靠上一些，也就是说如果两个都设置的话，显示的是 `backgroundImage` 的图片，不过如果你的图片如果有透明的话，也会透出 `barTintColor` 的颜色

如果 `backgroundImage` 设置为纯透明色，`tintColor` 也设置为纯透明色的话，这个时候导航条是黑色的，这个时候不能透出window的背景色或是 viewController 的颜色，并且，此时设置 bar 的 `backgroundColor` 是没有用的


在开启 `translucent` 的情况下
几乎一样，不过是在两个图层下面又可以透出 Window 或是 viewController 的背景色
如果 `backgroundImage` 设置为纯透明色，`tintColor` 也设置为纯透明色的话，此时设置 bar 的 backgroundColor 只会改变导航条的颜色，状态栏则会透视下去，显示的是 viewController 或是 window 的背景颜色


设置分割线的颜色需要使用 `shadowImage` 属性，你可以赋予一张图片，但是这个图片只有在导航条背景使用 `setBackgrounImage` 设置的时候才能默认启用，否则是没有用的

> 这里你可以这样认为， `backgroundImage`在第一层， `barTintColor`在第二层，`translucent`是第三层(YES的时候是模糊透明，NO的时候是黑色不透明的), `backgroundColor`是第四层（但是只能显示bar的44点高度的颜色，不能影响到status的颜色），通过层级，你就可以自由的控制你想要的效果了。

## 显示和隐藏
导航条的隐藏和显示可以通过 `navigationBar.hidden` 控制

### statusBar 显示和隐藏
如果 `View controller-based status bar appearance` 为 NO， 我们就只能使用全局控制。就是使用  **UIApplication.sharedApplication.statusBarHidden**
来控制，但是这里苹果已经不推荐了，因为一个地方的改动会影响整个应用

* 没用使用导航管理控制器时
通过重写方法**-（BOOL）prefersStatusBarHidden**来实现隐藏和显示`statusBar`
通过重写方法**- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation** 来控制状态栏显示动画
通过重写方法**- (UIStatusBarAnimation)preferredStatusBarStyle** 来控制状态栏样式

* 使用导航来管理控制器时
这个时候以上各个属性并不会被调用，我们需要实现一个导航控制器的子类，然后在实现中覆写方法
**-(UIViewController *)childViewControllerForStatusBarHidden**
**- (UIViewController *)childViewControllerForStatusBarStyle**
通过它返回你要控制的控制器就ok了，一般是返回**self.topViewController**

## 可能遇见的问题

**重写的方法不执行（实现了导航控制器子类后还是不执行）**
如果你从 vcA 使用 present 的方式跳转到 vcB，并且使用自定义动画(`UIViewControllerAnimatedTransitioning`)，上述方法也是不会执行的。解决方法是在 vcB 初始化的时候把 `modalPresentationCapturesStatusBarAppearance` 设为 `true`。这个属性决定 vcB 在非全屏模式下被 present 时，是否接管 statusBar 外观的控制权，默认为 NO。因为自定义动画属于非全屏的跳转，所以跳转以后的 vc 并没有获得 statusBar 外观的控制权，上面的方法就失效了，

**push 的时候导航条会黑一下**
一般是你实现一个导航控制器的子类，并用它 push 控制器的时候发生，可能是因为转场动画 containerView 的背景色的问题，你可以在导航控制器中设置自己的背景色是白色，就 ok 了

```swift
class ViewController: UIViewController {
    var isHidden:Bool = false
    @IBAction func clicked(sender: AnyObject) {
        isHidden = !isHidden
        UIView.animateWithDuration(0.5) { () -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    override func prefersStatusBarHidden() -> Bool {
        return isHidden
    }
}
```