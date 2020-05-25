---
title: 'ESP8266:MicroPython+WiFi+MQTT'
date: 2020-05-25 11:59:14
tags:
- ESP8266
- MicroPython
- WiFi
- MQTT
categories:
- hardware
---

## 连接 WiFi

#### 💢开启 WiFi 时报错 OSError: Cannot set STA config

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


## 连接 MQTT
