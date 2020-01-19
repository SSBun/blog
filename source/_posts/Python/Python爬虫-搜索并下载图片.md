---
title: Python爬虫搜索并下载图片
date: 2016-06-02 18:39:54
tags:
- Spider
categories:
- Python
---

本文是我学习Python爬虫的笔记,一直想要再学一门语言来扩展自己的知识面,看了看各种语言主要使用的方向,最后决心还是来搞一搞 `Python`.`Python` 给我的第一印象就是语法简洁,格式另类还有各种库的支持,就喜欢这么有个性的语言,为了以后深入的学习爬虫,事先肯定是先把语法学了一遍,下面是我实现的一个小爬虫,可以通过百度图库利用关键字来搜索图片并下载

## 工具准备:
* 不要多想,挑个IDE吧,我用的是[PyCharm](https://www.jetbrains.com/pycharm/)(免费的~嗯,今年刚刚免费的)
* 打开PyCharm的设置(找找在哪,我都是直接commond+,的,如果你有commond键的话)**在Project下选择Project Interpreter然后点击左下角的加号,在输入框中输入requests,收索后安装**,其实还有很多其他的安装方法,使用pip,在终端中敲入那些代码,然后还有什么其他的东西,不过还是这样比较偷懒(其实前面的坑我都爬过了)
* Python为最新版,2.7应该也没问题,并未使用Scrapy爬虫框架,也没有使用lxml,仅仅使用re正则和requests网络请求

## re和requests用法

- **re正则**
re就是正则,主要是用来解析数据的,当我们拿到网页的数据时需要从中提取处我们想要的数据,正则匹配就时其中的一个方法,至于正则的写法,这里就不在多讲,想看的在这里[正则表达式30分钟入门教程](http://deerchao.net/tutorials/regex/regex.htm),而re的常用使用手法可以在我的这篇文章里了解[Python爬虫-re(正则表达式)模块常用方法](http://www.jianshu.com/p/4177ab305bf4),这里我们主要使用其`re.findall("正则表达式","被匹配数据",匹配限制(例如:忽略大小写))`
- **requests网络请求**
requests的封装异常的强大,几乎可以做任何形式的网络请求,这里我们只是使用了其最简单的get请求`requests.get("url",timeout=5)`,详细了解,可以看一下([requests快速入门](http://blog.csdn.net/iloveyin/article/details/21444613))

### 具体的步骤
* 首先是想清楚想要做什么,你想要获取什么数据(没有目标哪来的动力啊),这里我们是想要通过百度图片来后去图片链接及内容,我想要搜索关键字,并可以指定搜索的数据量,选择是否保存及保存的路径~
* 需求有了,就要去分析要爬去的网页结构了,看一下我们的数据都在哪,我们这次要扒去的图片来自百度图片
* 首先进入百度图库,你所看见的页面当向下滑动的时候可以不停的刷新,这是一个动态的网页,而我们可以选择更简单的方法,就是点击网页上方的传统翻页版本

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119131915.png)

* 接下来就是我们熟悉的翻页界面,你可以点击第几页来获取更多的图片

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119131929.png)

* 点击鼠标的右键可以查看网页的源代码,大概就是这个样子的,我们get下来的数据,就是这个啦,我们需要在这里面找到**各个图片的链接**和**下一页的链接**,然而有点懵,这么多的数据,我们想要的在哪里呢?

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119131942.png)

* 不着急,我们可以通过浏览器的开发者工具来查看网页的元素,我用的是 Chrome,打开 Developer Tools 来查看网页样式,当你的鼠标从结构表中划过时会实时显示此段代码所对应的位置区域,我们可以通过此方法,快速的找到图片所对应的位置:

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119132000.png)

找到了一张图片的路径和下一页的路径,我们可以在源码中搜索结果找到他们的位置,并分析如何书写正则来获取信息:

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119132014.png)

* 所有的数据都分析完毕了,这个时候就要开始写我们的爬虫了,看了这么久,竟然一句代码都没有:

```python
import requests #首先导入库
import  re
```
然后设置默认配置

```python
MaxSearchPage = 20 # 收索页数
CurrentPage = 0 # 当前正在搜索的页数
DefaultPath = "/Users/caishilin/Desktop/pictures" # 默认储存位置
NeedSave = 0 # 是否需要储存
```

图片链接正则和下一页的链接正则

```python
def imageFiler(content): # 通过正则获取当前页面的图片地址数组
          return re.findall('"objURL":"(.*?)"',content,re.S)
def nextSource(content): # 通过正则获取下一页的网址
          next = re.findall('<div id="page">.*<a href="(.*?)" class="n">',content,re.S)[0]
          print("---------" + "http://image.baidu.com" + next) 
          return next
```

爬虫主体

```python
def spidler(source):
          content = requests.get(source).text  # 通过链接获取内容
          imageArr = imageFiler(content) # 获取图片数组
          global CurrentPage
          print("Current page:" + str(CurrentPage) + "**********************************")
          for imageUrl in imageArr:
              print(imageUrl)
              global  NeedSave
              if NeedSave:  # 如果需要保存保存
                 global DefaultPath
                 try:                
                      picture = requests.get(imageUrl,timeout=10) # 下载图片并设置超时时间,如果图片地址错误就不继续等待了
                 except:                
                      print("Download image error! errorUrl:" + imageUrl)                
                      continue            
                 pictureSavePath = DefaultPath + imageUrl.replace('/','') # 创建图片保存的路径
                 fp = open(pictureSavePath,'wb') # 以写入二进制的方式打开文件            fp.write(picture.content)
                 fp.close()
           else:   
                global MaxSearchPage
                if CurrentPage <= MaxSearchPage:
                    if nextSource(content):
                        CurrentPage += 1                                         
                        spidler("http://image.baidu.com" + nextSource(content)) # 爬取完毕后通过下一页地址继续爬取
```

爬虫的开启方法

```python
def  beginSearch(page=1,save=0,savePath="/users/caishilin/Desktop/pictures/"): # (page:爬取页数,save:是否储存,savePath:默认储存路径)
          global MaxSearchPage,NeedSave,DefaultPath
          MaxSearchPage = page
          NeedSave = save
          DefaultPath = savePath
          key = input("Please input you want search 
          StartSource = "http://image.baidu.com/search/flip?tn=baiduimage&ie=utf-8&word=" + str(key) + "&ct=201326592&v=flip" # 分析链接可以得到,替换其`word`值后面的数据来收索关键词
          spidler(StartSource)
```

调用开启的方法就可以通过关键词搜索图片了

```python
beginSearch(page=1,save=0)
```

## 小结
因为对 `Python` 的理解还不是特别的深入,所以代码比较繁琐,相比较爬虫框架 `Scrapy` 来说,直接使用 `reqests` 和 `re` 显得并不是特别的酷,但是这是学习理解爬虫最好的方式,接下来我会陆陆续续将我学习爬虫框架 `Scrapy` 的过程写下来,有错误的地方请指正。
