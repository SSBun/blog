---
title: AppleScript实现批量添加文件名前缀 
date: 2016-05-16 16:09:54
tags: 
categories:
- AppleScript
---

>AppleScript 是 Mac 系统提供的一个脚本语言，这个脚本语言简单易读，即使不会编程也能够很快的学会使用这种语言， AppleScript 可以让我们的日常工作流程化，简化繁琐的固定输入，自动化完成一般的日常工作。

首先是要打开 Mac 自带的脚本编辑器,直接搜索 Script Editor 就能够打开脚本编辑器

下面是源码

```AppleScript
property prifix : ""
display dialog "批量添加文件前缀名" default answer "" prifix buttons {"取消", "确定"} default button "确定" with title  "请输入前缀名"
set myResult to the result
if button returned of the myResult = "取消" then
    continue quit
end if
set prifix to text returned of myResult
on open frameworkFile
    tell application "Finder"
        set i to 1
        set maxCount to count of frameworkFile
        repeat maxCount times
            set theFile to item i of frameworkFile
            set name of theFile to (prifix & (name of theFile))
            set i to i + 1
        end repeat
    end tell
end open
```

**下面是行号及对应的作用**
- **1:** 定义一个属性用来储存你要的添加的前缀
- **2 - 7:** 当打开脚本时会弹出文本框用来录入你需要添加的前缀（默认会有上一次的前缀）
- **8:** 让你能够把需要更名的文件拖拽到脚本图标上执行
- **9 - 17:** 便利所有的文件对象，在它的名字上加上前缀

当你使用脚本的时候需要把它保存为 **`应用程序`** 因为只有这样才能够接受 `ON OPEN` 事件
还要勾上运行处理程序后保持打开，这样才能愉快的拖文件吗....
然后就没然后了，就是这么简单!
