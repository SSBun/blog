---
title: iOS截取特定的字符串(正则匹配)
date: 2016-6-15 11:21:54
tags:
- objc
categories:
- iOS
---

> 有时候我们会有需求从一个字符串中截取其他的字符串,根据情况的不同,我们来分析几种方法

## 固定长度字符串中截取固定位置长度的字符串

```swift
// 这是比较简单的一种情况:比如截取手机号的后4位
 let phoneNum = "18515383061"
 var suffixNum:String?
 // 从倒数第四位开始截取,截取到最后
 suffixNum = phoneNum.substringFromIndex(phoneNum.endIndex.advancedBy(-4))
 // 从开头截取到第三位,获取手机号前3位
 let prefixNum = phoneNum.substringToIndex(phoneNum.startIndex.advancedBy(3))
 // 截取区间内字符串
 suffixNum = phoneNum.substringWithRange(phoneNum.endIndex.advancedBy(-4)..<phoneNum.endIndex)
```

## 不固定长度的字符串,但是有分隔符

```swift
 //例如获取日期中的年,月,日
 // 分割符可以是任意的字符,一般为'/','_','空格',或者是特殊的字符.
 let timeStr = "2013/10/26"
 let timeArr = timeStr.componentsSeparatedByString("/")
 print(timeArr)
```

## 不固定长度的字符串,取特殊规则下的字符串

``` swift
 // 如下所示,我们想要截取第一个中括号里面的字符串
 // 假设这个字符串是服务器返回的,长度不定,中括号的位置也不定,先后通过简单的截取就比较困难了
 // 这个时候就要用到**正则表达式**,相信大家知道,但如何在Swift中利用正则表达式来筛选值呢,我们来分析一下
 // rangOfString本来是用来收索文中的字符串的,但是可以选择模式.这里选择(.RegularExpressionSearch)也就是正则的搜索
 // 但是OC和Swift中都只有这一种收索方法,只有Search,没有其他的,相比其他的语言(Python,PHP)弱太多了

 // 单纯匹配中括号里的字正则想必大家都会写 "\\[.*\\]",但是有一个问题就是收索的内容是'[thing] jflsdfs [do]',这显然不是我们想要的
 // 这就要收到正则的贪婪模式了,默认它尽可能多的匹配符合要求的字符串,而我们想让他满足最精巧的那个,就需要加上一个?号,就是这个样子"\\[.*?\\]",这样搜索到的就是'[thing]'
 // 你发现这还不是我们想要的,为什么要带上'['和']'呢,但是没办法,这是你的检索条件啊
 // 但是什么也难不倒正则,正则当中有 零宽断言,<零宽度正预测先行断言(?=exp)> 断言自身出现的位置的后面能匹配表达式exp, 
 // <零宽度正回顾后发断言(?<=exp)>，它断言自身出现的位置的前面能匹配表达式exp,最终我们的表达式是"(?<=\\[).*?(?=\\])"

 let string = "I Want to Do some [thing] jflsdfs [do]"
 if let result = string.rangeOfString("(?<=\\[).*?(?=\\])", options: .RegularExpressionSearch, range:string.startIndex..<string.endIndex, locale: nil)  {
         print(string.substringWithRange(result))
     }
```
> 学习正则这里来[正则表达式30分钟入门教程](http://deerchao.net/tutorials/regex/regex.htm)
