---
title: CALayer-Mask遮盖图层（iOS论文系列）
date: 2016-6-13 18:24:54
tags:
- Animation
- Layer
categories:
- iOS
---

**`mask` *Property***
*An optional layer whose alpha channel is used to mask the layer’s content.*
* **Declaration**

```swift
var mask: CALayer?
```

* **Discussion**
The layer’s alpha channel determines how much of the layer’s content and background shows through. Fully or partially opaque pixels allow the underlying content to show through but fully transparent pixels block that content.
The default value of this property is nil nil. When configuring a mask, remember to set the size and position of the mask layer to ensure it is aligned properly with the layer it masks.

* **Special Considerations**
The layer you assign to this property must not have a superlayer. If it does, the behavior is undefined.

* **Availability**
Available in iOS 3.0 and later.

以上是**Mask**在Apple的的官方文档中的描述,不难看出Mask在一般情况下是不存在,默认是nil.**Mask**相当于一个遮盖,覆盖在视图Layer的上层,如果将视图Layer称之为`ContentLayer`,可以通过控制**Mask**的`opacity(=alpha)`,`bounds`和`<path>路径`来控制`ContentLayer`的显示范围和透明度 
* 在**Mask**范围之外的`ContentLayer`将不被显示(相当于没有绘制在屏幕上,可以看到`ContentLayer`背后的视图)

* 在**Mask**范围之内的`ContentLayer = ContentLayer的opacity * **Mask**的opacity`,也就意味着**Mask**的`opacity`为0或1时`ContentLayer`显示或不显示,当其为0.x时`ContentLayer`为半透明状态

* 特别需要注意的是,**Mask**的背景色为`clearColor`也会被认为时`opacity`为0
 
**官方文档中已经警告:当你给Mask赋值时需要注意Mask不能拥有superLayer,否者Mask将会失效产生意想不到的后果**

**机智的小伙伴们可以发现Mask并没有指定图层类型,在大纲中,我们已经知道了CALayer的类型有很多种,这样的话就可以利用一些特殊的图层实现一些新奇的动画效果:**

* **此为一个类似于透镜的效果**

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119161428.gif)

```swift
import UIKit

class ViewController: UIViewController {
    
    var myImageView:UIImageView!
    var maskLayer:CAShapeLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        let image = UIImage(named: "_snqARKTgoc")

        let inputImage = CIImage(CGImage: image!.CGImage!)
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(inputImage, forKey: "inputImage")
        filter?.setValue(0.5, forKey: "inputBrightness")
        let outputImage = UIImage(CIImage: filter!.outputImage!)

        let bgImageView = UIImageView()
        bgImageView.image = outputImage
        bgImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width * (image!.size.height/image!.size.width));
        bgImageView.center = CGPointMake(self.view.center.x, self.view.center.y - 1)
        self.view.addSubview(bgImageView)
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width * (image!.size.height/image!.size.width));
        myImageView = imageView
        imageView.center = self.view.center
        self.view.addSubview(imageView)
        
        let shapLayer = CAShapeLayer()
        let path = CGPathCreateMutable()
        maskLayer = shapLayer
        shapLayer.bounds = CGRectMake(0, 0, 100, 100)
        CGPathAddEllipseInRect(path, nil, CGRectMake(0, 0, 100, 100))
        shapLayer.opacity = 0.5
        shapLayer.position = CGPointMake(200, 100)
        shapLayer.path = path
        shapLayer.fillColor = UIColor.blackColor().CGColor
        imageView.layer.mask = shapLayer
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.locationInView(self.view)
            if self.myImageView.frame.contains(touchPoint) {
                let realPoint = touch.locationInView(self.myImageView)
                maskLayer.position = realPoint
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
```
----
#####扩展:
* **使用其他的图层(`CAGradientLayer`)可以实现更多炫酷的效果,如iPhone的左滑解锁字体高亮,详细的实现方式会在后续的篇幅中结合`CAGradientLayer`一块总结**
