---
title: 使用 dumpdecrypted 砸壳时出现 Killed 9 的问题
date: 2018-07-25 10:39:54
tags:
categories:
- Jailbreak
---

这样一般是由于 `dumpdecrypted.dylib`  没有进行签名导致的，我们需要对它进行签名，下面是签名的方法

## 查看本地可用的证书

```bash
security find-identity -v -p codesigning
```
这里可以查看 Mac 上已经安装的开发者证书

## dylib 签名

```bash
codesign --force --verify --verbose --sign "iPhone Developer:" dumpdecrypted.dylib
```
成功以后，这个 `dumpdecrypted.dylib` 就已经是签名后的东西了，再次砸壳就就不会出现 `Killed: 9` 的问题了

## app 签名

这里补充一个 app 签名的方法
首先是查看App / dylib 的签名信息

```bash
codesign -vv -d Example.ipa
```

然后是通过证书对 App 进行签名

```bash
codesign -s 'iPhone Distribution: xxxx xxx Technology Co., Ltd.' Example.app
```

> 参考连接 ：[小谈签名工具ldid和codesign的使用](https://bbs.pediy.com/thread-218961.htm)
