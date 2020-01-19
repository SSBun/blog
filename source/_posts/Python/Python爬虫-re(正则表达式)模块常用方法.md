---
title: Python爬虫 re(正则表达式)模块常用方法
date: 2016-06-02 17:38:54
tags:
- Regular expression
categories:
- Python
---

**最近在学习使用Python来写爬虫,既然是学习爬虫,那肯定少不了筛选数据的神器-正则表达式,当然了强大的Python中也有正则表达式([正则表达式30分钟入门教程](http://deerchao.net/tutorials/regex/regex.htm))的模块,那就是`re`,下面就来了解一些我们常用的正则方法:**

## 常用匹配命令

### re.match
* re.match 模式:**从字符串的开始匹配一个满足对象**, 例如匹配第一个单词

```python
import re 
str = "my name is BZ, what's your name ?"
value = re.match(r"(\w+)\s", text)
if value:
     print(m.group(0))
else:
     print('not match')
```

* **re.match的函数为: `re.match(pattern,string,flags)` **
 * **pattern: 为正则表达式如`(\w+)\s`,如果匹配成功就返回小括号内匹配的数据**
 * **string: 要匹配的字符串 **
 * **flags: 用来控制正则表达式的匹配规则,如:是否区分大小写**

### re.search
* re.search 模式:**在字符串中查找匹配的对象,找到第一个后返回,如果没有返回None**
*  **re.search的函数为:`re.search(pattern,string,flags)`**
* **相比re.match只匹配开始而言,search会匹配所有,直到找到一个**

### re.sub
* re.sub 模式:**替换掉字符中的匹配项**
* re.sub的函数为:`re.sub(pattern,repl,string,count)`
 * **pattern: 要替换的正则表达式**
 * **repl: 替换后的字符串**
 * **string: 被匹配的字符串**
 * **count: 替换的次数,如果为零,默认替换所有匹配项**

### re.split
* re.split模式:**分割字符**,例如使用`re.split(r',',text)`将带`,`的字符串分割为数组

### re.findall
* re.findall 模式:**获取字符串中所有匹配的对象**
* **相比`re.search`而言会搜寻所有的可匹配对象**

### re.compile
* re.compile模式:**可以将一个正则表达式变成一个正则表达式对象,你可以使用它来匹配以上的各种规则,而不用重写正则表达式**,例如:

```python
import re
text = "my name is BZ, what's your name ?"
regex = re.compile(r'\w*BZ\w*')
print regex.findall(text) #查找所有包含'BZ'的单词
print regex.sub(lambda m: '[' + m.group(0) + ']', text) #将字符串中含有`BZ`的单词用`[]`括起来。
```

## flag的几种不同意义:
* **`re.I(re.IGNORECASE)`**: 忽略大小写（括号内是完整写法，下同
* **`M(MULTILINE)`**: 多行模式，改变'^'和'$'的行为
* **`S(DOTALL)`**: 点任意匹配模式，改变'.'的行为
* **`L(LOCALE)`**: 使预定字符类 \w \W \b \B \s \S 取决于当前区域设定
* **`U(UNICODE)`**: 使预定字符类 \w \W \b \B \s \S \d \D 取决于unicode定义的字符属性
* **`X(VERBOSE)`**: 详细模式。这个模式下正则表达式可以是多行，忽略空白字符，并可以加入注释.
