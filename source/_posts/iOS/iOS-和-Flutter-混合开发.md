---
title: iOS 和 Flutter 混合开发
date: 2020-05-06 14:52:00
categories:
- Flutter
---

Flutter 作为 Google 力推的跨平台开发框架，最近是越来越火了。最近恰逢我们的项目中有一个较为独立的模块，所以就决定拿它来试试水，正式的探索和使用一下 flutter 的技术。然后摆在面前的第一个问题就是该如果结合 Flutter 和 iOS 的项目呢？接下来就说一下我是如果在项目中管理 Flutter 和 iOS 项目的。

## 问题手册

> 更新 `Git` 异常的慢

这里我有 Shadowsocks 账号，可以通过设置 `git` 的 `socks5` 来解决问题

```
git config --global http.https://github.com.proxy socks5://127.0.0.1:1086
```
重置 `git` 配置

```
git config --global --unset http.https://github.com.proxy
```

> Cocoapods installed but not initialized.

卸载重装推荐版本的 cocoapods

```
sudo gem uninstall cocoapods
sudo gem install cocoapods -v 1.7.5  # Input the recommend version of Flutter.
pod setup
flutter doctor -v
```

> Invalid `Podfile` file: undefined method `pod' for main:Object.

删除 `.ios` 缓存，并重新构建

```
rm -rf flutter_modules/.ios
flutter build ios --debug

```

> This expression has type 'void' and can't be used

这是在使用 `Flutter-Boost` 的时候出现的问题，发现是 `Flutter-boost` 的版本和 `Flutter` 的版本不一致

> Building for iOS, but the linked and embedded framework 'App.framework' was built for iOS Simulator. (in target 'Runner' from project 'Runner')

在模拟器和真机之间切换执行 app 时，需要把已经生成的 `.framework`给清空掉

```bash
cd /flutter_project_path
flutter clean
rm -rf ios/Flutter/App.framework
```

## 集成方法

这里我们看一下目录结构：

```
App/
  - App_Flutter
  - App_iOS
  - App_Flutter_Pod
```

* `App_iOS` 是我们的 `iOS` 项目目录
* `App_Flutter` 是我们创建的 `Flutter Module` 项目
* `App_Flutter_Pod` 是我们为 `Flutter Moduel` 创建的 Pod

### 直接通过 Pod 本地导入 Flutter 库

我们进入到 `App_Flutter` 目录下，执行命令

```bash
flutter build ios
```
然后会构建 `release` 版本(构建命令后添加 `--debug`可以构建 debug版本的库，debug 版本下可以进行代码调试)的 Flutter 应用，构建完成以后，我们在进入到 `App_iOS` 目录下，通过 `Cocoapods` 导入本地的 Flutter 库

```bash
# 在 Podfile 的顶部，添加
flutter_application_path = '../App_Flutter'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'App_iOS' do
    ...
    # 安装所有依赖的 framework
    install_all_flutter_pods(flutter_application_path)
end
```

这种通过本地来构建和集成 flutter 的方法，适合单人开发，和调试的时候，修改 Flutter App 以后，能后快速验证与 iOS 原生的交互，缺点就是代码的编译需要安装 Flutter 环境，如果其他同事用不到 Flutter，也需要同时下载 Flutter 项目，才能编译 App。在实际开发环境当中，这样显得很麻烦。

### 通过生成一个 Cocoapod 库来引入 Flutter

上面我们说到了，直接引入 `App_Flutter` 编译生成的 framework 来集成 Flutter，既然是通过 Cocoapods 来安装 framework，到不如我们直接创建一个 Pod 仓库

我们在 `App` 目录下创建一个名为 `App_Flutter_Pod`的库
```
pod lib create App_Flutter_Pod
```

Pod 所需配置：

```
xingkunkun:FlutterForFW admin$ pod lib create MyFlutterPod
Cloning `https://github.com/CocoaPods/pod-template.git` into `MyFlutterPod`.
Configuring MyFlutterPod template.
------------------------------
To get you started we need to ask a few questions, this should only take a minute.

What platform do you want to use?? [ iOS / macOS ]
 > ios
What language do you want to use?? [ Swift / ObjC ]
 > objc
Would you like to include a demo application with your library? [ Yes / No ]
 > no
Which testing frameworks will you use? [ Specta / Kiwi / None ]
 > none
Would you like to do view based testing? [ Yes / No ]
 > no
What is your class prefix?
 > Kevin

Running pod install on your new library.
```

创建完成以后, 我们进入到 `App_Flutter_Pod` 目录中，创建一个脚本文件 `generatePod.sh`

```bash
#!/bin/bash

if [ -z $out ]; then
    out='ios_frameworks'
fi

if [ -z $app ]; then
    app='../App_Flutter'
fi

greenEcho() {
    echo -e "\033[32m${1}\033[0m"
}

greenEcho "Ready out put frameworkds to: $out"

greenEcho "Clean all old build files."
find $ap -d -name build | xargs rm -rf
(cd $app; flutter clean)
rm -rf $out

(cd $app; flutter packages get)

addFlag() {
    cat .ios/Podfile > tmp1.txt
    echo "use_frameworks!" >> tmp2.txt
    cat tmp1.txt >> tmp2.txt
    cat tmp2.txt > .ios/Podfile
    rm tmp1.txt tmp2.txt
}

greenEcho "Check $app/.ios/Podfile file state."

(cd $app;
a=$(cat .ios/Podfile)
if [[ $a == use* ]]; then
    greenEcho 'Already added use_frameworks'
else
    greenEcho 'No use_frameworks, ready add.'
    addFlag
    greenEcho "Adding use_frameworks finished."
fi
)

greenEcho "Build flutter framework"
(cd $app; flutter build ios-framework)
mkdir $out
if test $1 = 'debug'; then
    cp -r $app/build/ios/framework/Debug/*.framework $out
    greenEcho "### Debug Mode ###"
else
    cp -r $app/build/ios/framework/Release/*.framework $out
    greenEcho "### Release Mode ###"
fi

greenEcho "Copy framework to folder: $out"
```

我们使用 `flutter build ios-framework` 直接生成需要的 Framework, 然后再 `.podspec` 中导入生成的 framework，

```
  # 在 .podspec 底部加上下面的代码

  s.static_framework = true
  p = Dir::open("ios_frameworks")
  arr = Array.new
  arr.push('ios_frameworks/*.framework')
  s.ios.vendored_frameworks = arr
```

在 iOS 项目中进行 Pod 的引用

```bash
# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'

target 'iOSProject' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iOSProject
   pod 'App_Flutter_Pod', :path => '../App_Flutter_Pod'

end
```

这是在本地引用 Pod 库，当然我们可以将 Pod 库上传到 git 上，并通过指定远程路径，直接安装 framework，这就和普通的管理依赖没有区别了。麻烦的就是每次更新 Flutter 都需要重新打包上传，并 `pod install` 更新库，然后才能看见最终效果。
