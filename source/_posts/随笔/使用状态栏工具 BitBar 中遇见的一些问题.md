---
title: 使用状态栏工具 BitBar 中遇见的一些问题
date: 2019-11-20 10:29:54
tags:
- BitBar
- Develop
---

BitBar 是一个状态栏工具，它利用脚本的字符输出来构建 UI并且还能将结果显示到状态栏上。在简短的使用以后，我能想到的常用场景包括显示简短的监控信息(天气、监控信息等)以及执行常用命令(入是否显示隐藏文件、清空 Xcode 缓存等）。这些需求往往都很小、作用单一、常常使用但是用时又稍显麻烦，如果用一个独立软件来做，就显得更加麻烦了。而 BitBar 就是这样的小巧工具，恰好满足了我的需求，强大的语言支持（Shell、Python、JS、Swift 等）可以让我用熟悉的方法来实现我的需求。作为一个开源项目，网上也有众多开发者贡献出自己的插件，而这些插件也是完美的学习资料。下面是我编写的脚本，正好借用此脚本代码来说一些我编写监本时遇到的问题和经验：

```shell
#!/usr/local/bin/bash

# <bitbar.title>FlyCoding For BitBar</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>SSBun</bitbar.author>
# <bitbar.author.github>https://github.com/SSBun</bitbar.author.github>
# <bitbar.image>https://avatars3.githubusercontent.com/u/13583118?s=460&v=4</bitbar.image>
# <bitbar.desc>Small tools for iOS developers</bitbar.desc>


# Helper
utilPath() {
	user=`echo ~`
	path="$user/Desktop/BitBar/utils/$1"
	echo $path
}

##### About Finder #####

# Display all hidden files.
# - param1: Either 1 or 0, 1 display, 0 hide.
showAllFiles() {
	show=YES
	if [ $1 -eq 1 ]; then
		show=YES
	else
		show=NO
	fi
	defaults write com.apple.finder AppleShowAllFiles $show; killall Finder /System/Library/CoreServices/Finder.app
	return 0
}

# Remove Xcode derived data folder.
cleanXcodeDerivedFolder() {
	xcodeDerivedFolderPath="`echo ~`/Library/Developer/Xcode/DerivedData"	
	rm -r $xcodeDerivedFolderPath
	osascript -e 'display notification "Clean Xcode derived data completion." with title "FlyCoding-BitBar"'
}

# Eject all disk on Desktop
ejectAllDisksOnDesktop() {
	path=`utilPath EjectDisk`
	open path
	if test $? -eq 0; then
		osascript -e 'display notification "Eject all disks completly" with title "FlyCoding-BitBar"'		
	else
		osascript -e 'display notification "Eject all disks failuer" with title "FlyCoding-BitBar"'		
	fi
}

# Get Beijing weather.
getBeijingWeather() {	
	user=`echo ~`
	path=`utilPath weather.py`
	result=`python3 $path`
	if test ${#result} -ge 1; then
		str=""
		index=0
		oldIFS=$IFS
		IFS=,
		
		for item in $result;
		do
			if test $index -eq 0; then
				str+="\e[1;32m $item \e[0m"
			elif test $index -eq 1; then
				str+="\e[1;32m $item \e[0m"
			elif test $index -eq 2; then
				str+="\e[1;34m $item \e[0m"
			elif test $index -eq 3; then
				str+="\e[1;31m $item \e[0m"
			fi
			let index+=1
		done
				
		IFS=$oldIFS		
		echo -e $str
		return 0
	fi
	echo $result
}

##### Execute script ######
if test $# -ge 1; then
	method=$1
	shift
	$method $*
	
	# Default return succes code.
	return 0
fi


# The path of current shell file.
path="`pwd`/$0"
path=${path//' '/'\ '}


#echo Bit bar
echo "🚀 `getBeijingWeather` 🚀 | font='Arial Rounded MT Bold"
echo ---
echo Finder
echo -- Display all files ?
echo "---- ✅ YES | bash="$path" param1=showAllFiles param2=1 terminal=false"
echo "---- ❌ NO | bash="$path" param1=showAllFiles param2=0 terminal=false"
echo "-- Clean Xcode derived folder | bash="$path" param1=cleanXcodeDerivedFolder terminal=false"
echo "-- Eject all disks on Desktop | bash="$path" param1=ejectAllDisksOnDesktop terminal=false"

```

### 注意路径中不要带空格
  BitBar 是通过`指定脚本路径，然后默认运行该路径下的脚本并处理输出结果来实现主要功能的`。我最开始想要将路径指定在 **iCloud** 目录下，这样就可以自动同步到我所有的 Mac设备上（当然用 Git 可能是更合理的方法，但我懒啊😂），可是执行代码的时候报了**路径错误**，就是因为 BitBar 执行脚本时直接将脚本目录作为命令参数执行，遇见空格后 bash 命令接到的路径地址就到此结束了，导致无法找到目录。这里有心的小伙伴可以通过修改源码修复这个 bug，我就直接换了一个路径。

### 如何执行其他脚本文件
在编写 BitBar 脚本时，如果功能比较多代码量比较大，直接放在一个文件里面不好管理。也有可能你的不同功能使用不同的语言来实现的。这个时候你就需要执行外部脚本来实现想要的功能了，BitBar 提供了 `bash="$path" param1=cleanXcodeDerivedFolder terminal=false"` 命令来执行外部脚本，`bash`后面是脚本路径， `param1、param2...`是参数， 最后的 `terminal=false`  则表示执行脚本时不显示终端界面（因为执行过程就是调起一个新终端执行脚本），但是这里有一个 **bug** 就是在 `terminal=false` 的情况下，执行外部脚本的代码可能没有效果，如果设置`terminal=true`就会在执行的时候打开一个新的终端，这样就显的忒 low 了。当然在网上也有很多人提出这个问题，这里就不说什么原因导致的了。我搜索尝试了一些解决办法以后，这里给出一个我的最终解决方案：

首先推荐大家在写 BitBar 脚本时用 `bash/zsh`等 Shell 语言来写，然后扩展功能用更方便的语言来写。
**而解决这个问题的方法就是，我们不让 BitBar 通过 `bash="$path"` 的路径去调用其他的脚本，而是让它执行自己，所以这里的 `$path` 传的是 BitBar 脚本的路径。 然后我们再通过脚本中的方法去主动调用其他脚本，就可以解决这个问题了。🤡**

```bash
# The path of the current shell file.
path="`pwd`/$0"
path=${path//' '/'\ '}
```
上述代码来获取当前脚本文件的地址

```bash
echo "-- Clean Xcode derived folder | bash="$path" param1=cleanXcodeDerivedFolder terminal=false"
```
这是一个清理 Xcode 缓存文件夹的命令，我要执行脚本`$path`是自己，而`param1`则是一个方法名，然后编写一个方法`cleanXcodeDerivedFolder`放到主脚本里面。

```bash
##### Execute script ######
if test $# -ge 1; then
	method=$1
	shift
	$method $*
	
	# Default return succes code.
	return 0
fi
```
但再度执行当前脚本时，首先通过 `test $# -ge 1` 判断是否有参数，BitBar 自己调用脚本的时候是没有添加参数的，就会继续执行后续的代码，而我们在的执行其他脚本的操作中添加了参数，这里就会拦下命令并通过 `$1` 的方法名和后续的参数去执行指定的方法。

### 结
解决了调用其他脚本的问题以后，你就能随心所欲的编写各种各样的脚本来丰富你的 BitBar 了，如果这篇文章恰巧解决了你的问题，举手之劳点个赞吧。