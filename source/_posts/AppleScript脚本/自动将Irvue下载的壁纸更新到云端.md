---
title: 自动将 Irvue 下载的壁纸更新到云端
date: 2016-06-12 13:59:54
categories:
- AppleScript
---

> 首先给大家推荐一个Mac上的壁纸软件Irvue,这是可以自动更换桌面壁纸的软件,而其不同于其他软件的是,它的图片库来源于一个外国的图片共享网站,站内都是优质的高清摄影大图,真正的每一张图都能带你不同的感觉~

但是当我将喜欢的图片下载到本地后,想要时实保存到 Github 上时,而又不希望每次都提交文件时,这个小脚本就犹然而生了

```AppleScript
repeat
    uploadPicture()      
    delay 60 * 30    // 一旦开启执行后没30分钟执行一次
end repeat
property lastFolderCount : 0
on uploadPicture()
    tell application "Finder"
        set pictureFolder **to** *alias* "Macintosh HD:Users:caishilin:Pictures"
        items of pictureFolder
        if (count of items) is not equal to lastFolderCount then // 通过文件的数量来判断是否本地文件变更
            set lastFolderCount to count of items
            tell application "Terminal"
                do script "cd /Users/caishilin/Pictures/Irvue" & return & "git add ." & return & "git commit -m \"add\"" & return & "git push origin master"  // 通过控制terminal来提交更新到远程库
            end tell
        end if
    end tell
end uploadPicture
```
**在使用的过程中有几点需要注意:**
* 建立远程库后需要先通过账号密码链接到远程库
* 检测路径根据你所设置的 Irvue 的下载路径来更改
