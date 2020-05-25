---
title: IoT:MQTT+mosquitto
date: 2020-05-22 12:17:55
tags:
- MQTT
- mosquitto
categories:
- hardware
---


## 2. MicroPython 编程

### 2.1 在 ESP8266 执行代码

这里我用的是 Mac 系统，习惯使用 `VSCode` 进行代码编写，配合 PlatformIO 可以进行各种硬件设备代码的编写和调试，在写 `MicroPython` 的时候，我们可以安装一个插件 `RT-Thread MicroPython` 可以提供代码提示，并且它还提供了一些实例代码和 Demo。

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