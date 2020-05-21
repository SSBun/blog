---
title: MicroPython For ESP8266
date: 2020-05-21 10:28:42
tags:
- hardware
---

## 1 安装 MicroPython 到 ESP8266

### 1.1 硬件准备

1. 一片 `ESP8266`， 它的 `flash size` 最低要求为 `1MB`
2. 串口工具，例如 `CH340`。如果你使用的是类似 `NodeMCU` 的开发板，它自带了串口芯片可以直接使用

### 1.2 下载 MicroPython 固件

[MicroPython 官方下载地址](http://micropython.org/download/#esp8266)，下载页面可以选择芯片类型，这里选择 ESP8266。 版本推荐使用 `Stable firmware` 稳定版, 如果你想使用更多的特性，可以尝试一下 `Daily firmware` 版本。

### 1.3 烧录 MicroPython 固件

烧录固件需要用到 `esptool` 工具，这是[esptool 下载地址](https://github.com/espressif/esptool/),也可以使用 `pip` 来安装

```bash
pip install esptool
```

首先需要擦除 ESP8266 flash, 这里的 `port` 是你的串口号，我平时开发使用的是 VSCode 中的 PlatformIO，可以顺便查看串口设备。

```bash
esptool.py --prot /dev/ttyUSE0 erase_flash
```

写入 `MicroPython` 固件

```bash
esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash --flash_size=detect 0 esp8266-20191220-v1.12.bin
```

### 1.4 连接 ESP826

上述步骤完成以后，`ESP8266` 内部就运行了一个精简版本的 Pyton 环境, 我们想要连接它有两种方式：**串口调试**和**WebREPL**。

#### 1.4.1 通过串口连接 ESP8266

使用 PlatformIO 的串口监视器，我们可以连接 `ESP8266`, 然后再窗口中会显示 `>>>`, 表示你已经进入到了 `Python` 环境当中。

#### 1.4.2 使用 WebREPL 连接 ESP8266

首先我们下载 [WebREPL 工具](https://github.com/micropython/webrepl) 到本地。`WebREPL` 提供了一个通过 WiFi 远程调试的功能，我们可以远程更新和下载 flash 中的文件。

ESP8266 在烧录完成后，会自动开启一个 WiFi 站点，名字为 `MicroPython-xxxxxx`, 密码是 `micropythoN`。在进入 `WebREPL` 之前我们需要提前进行设置，通过串口工具连接进去，执行以后命令会让你设置连接密码。

```python
import webrepl_setup
```

然后连接 ESP8266 的 WiFi，点击 connect 进行连接，输入密码，连接成功以后，就可以在线执行命令或更改和提交文件了。

## 2. MicroPython 编程

### 2.1 在 ESP8266 执行代码

代码编写完成以后需要通过某些方式导入 ESP8266 执行，**第一种**方法是通过串口，进入 Python 环境直接编辑代码， 不过此方法并不适合大文件。**第二种**这是通过 WebREPL 导入代码文件，然后硬件 reset 执行 `main.py` 函数。

这里我用的是 Mac 系统，特别推荐使用 `VSCode` 进行代码编写，配合 PlatformIO 可以进行各种硬件设备代码的编写和调试，在写 `MicroPython` 的时候，我们可以安装一个插件 `RT-Thread MicroPython`，下面列出它的功能描述：

- 设备快速连接 (串口， 网络，USB)
- 支持基于 MicroPython 的代码智能提示补全和语法检测
- 支持 MicroPython REPL 交互环境
- 提供丰富的代码示例和 demon 程序
- 提供工程同步功能
- 支持下载单个文件或文件夹到开发板
- 支持在内存中快速运行代码文件功能
- 支持运行代码片段功能
- 支持多款主流 MicroPython 开发板

实际使用中，这个插件用起来也是非常的爽，编辑调试速度很快，基本上写完，点一下上传就 ok 了。


## 3 问题总结

### 3.1 开启 WiFi 时报错 OSError: Cannot set STA config

```python
wlan = network.WLAN(network.STA_IF)
```

这个时候，我们在交互式命令行下，执行以下代码，激活后，再重试就可以了

```python
import network

wlan = network.WLAN(network.STA_IF) # create station interface
wlan.active(True)       # activate the interface
wlan.scan()             # scan for access points
```