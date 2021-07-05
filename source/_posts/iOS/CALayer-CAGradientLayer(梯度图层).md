---
title: CALayer-CAGradientLayer(梯度图层)
date: 2016-6-16 18:58:54
tags:
- Animation
- Layer
categories:
- iOS
---

***CAGradientlayer可以绘制一个充满整个图层的颜色梯度(包括原型图层等图层)在一个背景颜色上***

> 在了解`CAGradientLayer`之前,我们先要了解一下`CALayer`的坐标,如下图,一个Layer的左上角为(0,0),其右下角坐标为(1,1),中心点是(0.5,0.5),任何图层都是如此,和父图层以及自身的形状无关.

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119160805.png)

## 属性
* **colors** 
**`var colors: [AnyObject]?`**
一个内部是`CGColorRef`的数组,规定所有的梯度所显示的颜色,默认为nil

* **locations**
**`var locations: [NSNumber]?`**
一个内部是`NSNumber`的可选数组,规定所有的颜色梯度的区间范围,选值只能在0到1之间,并且数组的数据必须单增,默认值为nil

* **endPoint**
**`var endPoint: CGPoint`**
图层颜色绘制的终点坐标,也就是阶梯图层绘制的结束点,默认值是(0.5,1.0)

* **startPoint**
**`var startPoint: CGPoint`**
与`endPoint`相互对应,就是绘制阶梯图层的起点坐标,绘制颜色的起点,默认值是(0.5,0.0)

* **type**
**`var type:String`**
绘制类型,默认值是`kCAGradientLayerAxial`,也就是线性绘制,各个颜色阶层直接的变化是线性的

## 实例

通过属性大家都差不多知道该如何使用阶梯图层了,接下来我们看一下普通的例子,然后讨论几种情况

```swift
//
//  ViewController.swift
//  CALayer-CAGradientLayer
//
//  Created by 蔡士林 on 6/16/16.
//  Copyright © 2016 BZ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 创建阶梯图层
        let gradientLayer = CAGradientLayer()
        // 设置阶梯图层的背景
        //gradientLayer.backgroundColor = UIColor.grayColor().CGColor
        // 图层的颜色空间(阶梯显示时按照数组的顺序显示渐进色)
        gradientLayer.colors = [UIColor.redColor().CGColor,UIColor.blueColor().CGColor,UIColor.greenColor().CGColor]
        // 各个阶梯的区间百分比
        gradientLayer.locations = [0.1,0.6,1]
        gradientLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)
        gradientLayer.position = self.view.center
        // 绘图的起点(默认是(0.5,0))
        gradientLayer.startPoint = CGPointMake(1, 0)
        // 绘图的终点(默认是(0.5,1))
![Uploading (0,0.5)(1,0.5)@2x_114834.png . . .]

        gradientLayer.endPoint = CGPointMake(0, 1)
        self.view.layer.addSublayer(gradientLayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
```
**系统默认的绘制方向,从上往下的**

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119160840.png)

**这是起点为(0,0.5),终点(1,0.5),时横向绘制**

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119160854.png)

**以起点和终点所画出来的直线做中心轴绘制**

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119160905.png)

## 动画

**`CAGradientLayer`的所有属性都能产生隐式动画我们可以通过NSTimer来定时修改Location(其他的也可以(⊙o⊙)哦)**

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119160926.webp)


```swift
//
//  ViewController.swift
//  CALayer-CAGradientLayer
//
//  Created by 蔡士林 on 6/16/16.
//  Copyright © 2016 BZ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var graLayer:CAGradientLayer!
    var index = 0.1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.backgroundColor = UIColor.grayColor().CGColor
        gradientLayer.colors = [UIColor.redColor().CGColor,UIColor.blueColor().CGColor,UIColor.greenColor().CGColor]
        gradientLayer.locations = [0.1,0.15,1]
        gradientLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)
        gradientLayer.position = self.view.center
        gradientLayer.startPoint = CGPointMake(1, 0)
        gradientLayer.endPoint = CGPointMake(0, 1)
        self.graLayer = gradientLayer
        self.view.layer.addSublayer(gradientLayer)
        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: #selector(ViewController.change), userInfo: nil, repeats: true)
    }
    
    func change(){
        index = index + 0.01
        let twoIndex = index + 0.05
        graLayer.locations = [index,twoIndex,1]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
```
> 当然了你也可以设置它的其他属性来实现各种各样的动画,你可以充分发挥你的想象力~
