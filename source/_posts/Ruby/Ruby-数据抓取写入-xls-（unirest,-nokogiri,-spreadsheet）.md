---
title: Ruby 数据抓取写入 xls（unirest, nokogiri, spreadsheet）
date: 2017-03-13 10:14:00
tags:
- Ruby
categories:
- Ruby
---

## 安装 unirest
使用 python 进行数据请求，我们可以使用 `opne-uri`，但是进行各种类型的请求时，显得不是特别的方便快捷，所以我们使用`unirest`来进行网络数据请求。

```
gem install unirest // 安装 unirest
```
### unirest 的用法
uinirest最低支持 Ruby2.0版本，使用起来十分的简单，常用的方法有下面几个 (具体的使用方法可以看[**unirest.io**](http://unirest.io/ruby.html))

#### 创建请求

```python
response = Unirest.post "http://httpbin.org/post", 
                        headers:{ "Accept" => "application/json" }, 
                        parameters:{ :age => 23, :foo => "bar" }

response.code # Status code
response.headers # Response headers
response.body # Parsed body
response.raw_body # Unparsed body
```
#### 异步请求

```python
response = Unirest.post "http://httpbin.org/post", 
                        headers:{ "Accept" => "application/json" }, 
                        parameters:{ :age => 23, :foo => "bar" } {|response|
    response.code # Status code
    response.headers # Response headers
    response.body # Parsed body
    response.raw_body # Unparsed body
}
```
####  基本 get 请求

```python
response = Unirest.get "http://httpbin.org/get", auth:{:user=>"username", :password=>"password"}
```

## 安装 nokogiri
当我们爬取到数据后，我们需要对数据进行分析，如果是简单的数据结构我们可以直接使用`正则表达式`，如果数据的结构比较复杂，我们就需要使用 nokogiri 对 html 的 dom 进行操作，如果对 dom 结果不了解可以先查看相关的内容(html dom教程)[http://www.runoob.com/htmldom/htmldom-tutorial.html]

```
gem install nokogiri
```
### nokogiri 使用

#### 导入包
```python
require 'rubygems'
require 'nonogiri'

```
#### 打开一个 html 文档

```python
page = Nokogiri::HTML(open("index.html))
puts page.class # => Nokogiri::HTML::Document

# 你也可以直接使用 unirest 请求下来的数据 response.body 来进行解析
response = Unirest.get "http://httpbin.org/get"
page = Nokogiri::HTML(response.body)
```
#### 通过 open-uri 直接解析 url
通过 http 请求直接获取到 document

```python
require 'rubygems'
require 'nokogiri'
require 'open-uri'
   
page = Nokogiri::HTML(open("http://en.wikipedia.org/"))   
puts page.class   # => Nokogiri::HTML::Document
```
#### CSS 选择器
对 Document 对象进行节点分析

```python
page.css('title') # 查找 page 下所有的 `title` 标签, 返回的是一个数组
page.css('li')[0].text # 获取 page 下第一个 `li` 标签中的内容
page.css('li')[0]['href'] # 获取第一 `li` 标签中属性 `href` 的值
page.css("li[data-category='news']") #获取属性有 `data-category='news'` 的 `li` 标签
page.css('div#funstuff')[0] #获取标签 `id='funstuff'` 的节点
page.css('div#reference a') # 获取标签 `id='reference'` 下所有的 `a` 节点 
```
更多的关于 `nokogiri` 的信息可以通过[**Parsing HTML with Nokogiri**](http://ruby.bastardsbook.com/chapters/html-parsing/)进行了解

## 安装 spreadsheet
Spreadsheet是一个Ruby实现的gem，它可以使我们很方便的使用它对excel进行操作，我们需要将获取到的数据存入本地，方便数据的记录和后续处理。

```python
# 引入spreadsheet插件
require "spreadsheet"

# 声明Spreadsheet处理Excel文件组时的编码
Spreadsheet.client_encoding = "UTF-8"

# 创建一个Spreadsheet对象，它相当于Excel文件
book = Spreadsheet::Workbook.new
# 创建Excel文件中的一个表格，并命名为 "Test Excel"
sheet1 = book.create_worksheet :name => "Test Excel"

# 设置一个Excel文件的格式
default_format = Spreadsheet::Format.new(:weight => :bold,#字体加粗
                             :size => 14, 
                             :horizontal_align: => :merge, #表格合并
                             :color=>"red", 
                             :border=>1, 
                             :border_color=>"black",
                             :pattern => 1 ,
                             :pattern_fg_color => "yellow" )#这里需要注意，如果pattern不手动处理，会导致pattern_fg_color无实际效果

# 指定一个在表格中的第一行对象
test_row = sheet1.row(0)
test_row.set_format(i, default_format)

# 为第一行的第一列指定值
test_row[0] = "row 1 col 1"
# 为第一行的第二列指定值
test_rwo[1] = "row 1 col 2" 

# 将创建的Spreadsheet对象写入文件，形成电子表格
book.write 'book2.xls'
```

## 爬虫
爬取 **RUNOOB.COM(http://www.runoob.com/)** 的教程列表和地址数据
其实这都算不上是一个爬虫，但是作为利用 ruby 的各种 gem 来实现异步数据请求，数据筛选及存储。是实现一个更加复杂的爬虫的必备工具。熟练的使用各种各样的 gem 可以体现 ruby 的简洁

```python
#!/usr/bin/ruby
require 'unirest'
require 'nokogiri'
require 'open-uri'
require 'spreadsheet'

# 获取网页的信息
response = Unirest.get "http://www.runoob.com/"
page = Nokogiri::HTML(response.body)

# 获取大分类的列表
datas = page.css('div.codelist')
puts datas.count

# 创建一个表格
Spreadsheet.client_encoding = 'UTF-8'
book = Spreadsheet::Workbook.new

# 创建一个 sheet
sheet = book.create_worksheet :name => "my excel"

index = 0
datas.each do |category|
	puts category.css('h2').text # 获取大分类的名字
	items = category.css('a.item-top') 
	items.each do |item|		
		sheet.row(index)[0] = item.css('h4').text # 写入教程的名字
		sheet.row(index)[1] = item['href'] # 写入教程的链接
		index += 1
	end
end

book.write '/users/ssbun/desktop/runoob.xls' # 写入本地文件 （**注意你的路径**）
```

随后你就可以看见在你的桌面上有一个 xls 文件，打开它就能看到里面的数据了。
