---
title: CALayer-绪论
date: 2016-6-13 18:26:54
tags:
- Animation
- Layer
categories:
- iOS
---

今天在处理一些问题的时候，又牵扯到了图层的处理，然后开始发掘大脑深处的记忆，不过，O(∩_∩)O~发现自己又忘的差不多了，然后开始查看一些关于`CALayer`的资料，花费的时间不多，但是感觉这已经是我第N+N次查看这些东西了（*感觉自己好笨*～)，每次都会浪费时间来收索想要的东西，但也从来没有对`CALayer`有任何系统的了解，总是在使用的过程中，突然发现：我擦，怎么会有这个子类；这个，我怎么不知道有这个属性。终于我不能忍了，就是现在，我要回归修真模式，好好的整理一下这个～常用但又不常用～的家伙，也作为我《iOS论文系列》的开篇之作。

## 继承关系
* **NSObject**
   *  **CALayer**
      1. **AVCaptureVideoPreviewLayer**（多媒体捕获视频预览图层)
      2. **AVPlayerLayer**（多媒体播放图层）
      3. **AVSampleBufferDisplayLayer**（多媒体缓冲显示图层）
      4. **AVSynchronizedLayer**（多媒体同步图层）
      5. **CAEAGLLayer**（(⊙o⊙)...）
      6. **CAEmitterLayer**（粒子发射图层）
      7. **CAGradientLayer**（梯度显示图层）
      8. **CAMetalLayer**（金属图层）
      9. **CAReplicatorLayer**（复制图层）
      10. **CAScrollLayer**（滚动图层）
      11. **CAShapeLayer**（形状图层）
      12. **CATextLayer**（文本图层）
      13. **CATiledLayer**（瓷砖图层）
      14. **CATransformLayer**（转换图层）      

## 遵守协议
+ **CAMediaTiming**  
+ **CVarArgType**  
+ **CustomStringConvertible**
+ **Equatable**
+ **Hashable**  
+ **NSCoding** 
+ **NSObjectProtocol**

## 引入头文件
```
	SWIFT:
		import QuartzCore
	OBJECTIVE-C
		@import @"QuartzCore";
```
## 支持
+ **支持iOS2.0以后**

## 简介
CALayer主要是用来管理基于图像的内容，并允许你执行动画在它的上面。图层一般是用来做View（视图）内容的容器但是也可以脱离View而直接显示内容。一个Layer的主要工作是管理显示你所提供的视觉内容，但是其内部有很多视觉属性可以被设置，例如：（backgroundColor）背景色，(border)边框，(shadow)阴影等。除了管理视觉内容，Layer还维持其在屏幕上显示的图形信息（例如：(中心点位置)position,(大小)size,(形变信息)transform），修改Layer的属性能够让你开启一个动画，一个Layer对象可以设置动画时长和步调（节奏），其动画采用`CAMediaTiming`协议，它定义了图层的定时信息。  

如果一个Layer通过一个View被创建，View通常自动给自己分配Layer的代理，一般情况下，不要改变它们之间的关联。如果你自己创建一个Layer,你可以设置一个代理(delegate)对象，并通过它来动态设置Layer的内容或执行其他的任务，一个Layer也有可能会有一个布局管理者对象（设置`LayoutManager`属性）去分别管理子视图的布局。

## 目录:
* [CALayer-Mask遮盖图层](http://www.jianshu.com/p/d9f8a1796e2a)
* [CALayer-CAGradientLayer(梯度图层)](http://www.jianshu.com/p/1c8ef3116b42)
* [CALayer-CAReplicatorLayer(复制图层)](http://www.jianshu.com/p/84455b674f55)
* [CALayer-CAEmitterLayer(粒子图层)](http://www.jianshu.com/p/3dbccd78ee91)
**持续更新中...**
