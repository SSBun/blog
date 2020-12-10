---
title: CALayer-CAEmitterLayer(粒子图层)
date: 2016-6-28 18:32:54
tags:
- Animation
- Layer
categories:
- iOS
---

> `CAEmitterLayer`能够显示粒子效果通过Core Animation,而粒子是通过`CAEmitterCell`来创建的,这些粒子被绘制在图层的背景上方

## 指定的粒子属性
***emitterCells***
**`var emitterCells: [CAEmitterCell]?`**
所有在数组中的粒子都会被随机的绘制在图层上

## 粒子几何属性
***renderModel***
**`var renderMode: String`**
控制粒子的渲染模式,(比如是否粒子重叠加重色彩)默认值是`kCAEmitterLayerUnordered`.
* `let kCAEmitterLayerUnordered: String`    无序随机的
* `let kCAEmitterLayerOldestFirst: String`    最新的在上层出现
* `let kCAEmitterLayerOldestLast: String`     最新的在下层出现
* `let kCAEmitterLayerBackToFront: String`  由下层向上层涌动
* `let kCAEmitterLayerAdditive: String`         叠加显示

***emitterPosition***
**`var emitterPosition: CGPoint`**
在粒子图层上粒子的发射点(支持隐式动画)

***emitterShape***
**`var emitterShape: String`**
粒子发射点图形形状
* `let kCAEmitterLayerPoint: String`           点
* `let kCAEmitterLayerLine: String`            线形
* `let kCAEmitterLayerRectangle: String`   矩形
* `let kCAEmitterLayerCuboid: String`       长方体
* `let kCAEmitterLayerCircle: String`          圆形
* `let kCAEmitterLayerSphere: String`        球体

***emitterZPosition***
**`var emitterZPosition: CGFloat`**
粒子发射器的z轴中心,这个需要结合`emitterSize`和`emitterDepth`来使用,主要是用来设置`emitterShape`的.默认值是0

***emitterDepth***
**`var emitterDepth: CGFloat`**
粒子发射器的深度,也就是y轴的高`emitterZPosition`就是这个Z轴的中心

***emitterSize***
** `var emitterSize: CGSize` **
这个就是粒子发射器的shape的大小,控制`emitterShape`的大小


***emitterMode***
**`var emitterModel: String`**
粒子发射器的模式
* `let kCAEmitterLayerPoints: String`
* `let kCAEmitterLayerOutline: String`
* `let kCAEmitterLayerSurface: String`
* `let kCAEmitterLayerVolume: String`



#### CAEmitterCell的基础属性
***scale***
**`var scale: Float`**
设置粒子发射器的生成粒子的初始缩放比例

***speed***
**`var speed: UInt32`**
粒子发射器的粒子发射速度

***spin***
**`var spin: CGFloat`**
设置粒子的自旋速度,数值越大旋转越快

***velocity***
**`var velocity: Float`**
设置粒子的移动速度(支持隐式动画)默认值是1.0

***birthRate***
**`var birthRate: Float`**
每秒生成的粒子数量,默认值是1(支持隐式动画)

***lifetime***
**`var lifetime: Float`**
设置粒子的生存时间(支持隐式动画)默认是1.0

> **其实用起来比较简单,所以先看一个例子,用起来好晃眼~~~**

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119160402.gif)

```swift
//
//  ViewController.swift
//  CAEmitterLayer
//
//  Copyright © 2016 BZ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var emitterLayer:CAEmitterLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        emitterLayer                 = CAEmitterLayer()
        self.view.layer.addSublayer(emitterLayer)
        emitterLayer.backgroundColor = UIColor.blackColor().CGColor
        let screenWidth              = self.view.bounds.size.width
        emitterLayer.frame           = CGRectMake(0, 0, screenWidth, screenWidth)
        emitterLayer.position        = self.view.center
        emitterLayer.emitterPosition = CGPointMake(emitterLayer.bounds.size.width/2, emitterLayer.bounds.size.height/2)
        emitterLayer.renderMode      = kCAEmitterLayerUnordered;
        emitterLayer.emitterShape    = kCAEmitterLayerPoint; 发射器形状
        emitterLayer.emitterSize     = CGSizeMake(200, 200); // 发射器大小

        let emitterCell              = CAEmitterCell()
        emitterCell.scale = 0.2
        emitterCell.contents         = UIImage(named: "123")?.CGImage
        emitterCell.birthRate        = 100       //出生率
        emitterCell.lifetime         = 5            //生存时间
        emitterCell.velocity         = 50          //发射速度
        emitterCell.velocityRange    = 100    //发射的范围
        emitterCell.alphaSpeed       = -0.4  //透明度递增速度
        emitterCell.emissionRange    = CGFloat(M_PI*2.0) 发射角度
        emitterLayer.emitterCells    = [emitterCell]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
```
 
![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119160429.gif)
