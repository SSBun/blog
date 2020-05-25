---
title: 'IoT:HomeAssistant'
date: 2020-05-25 11:57:45
tags:
- HomeAssistant
categories:
- hardware
---


[Home-Assistant](https://home-assistant-china.github.io/)

在 Mac 上安装 Home-Assistant [安装教程](https://home-assistant-china.github.io/developers/development_environment/)



[MQTT](https://www.ibm.com/developerworks/cn/iot/iot-mqtt-why-good-for-iot/index.html)
物联网协议标准
[mosquitto 下载地址](https://mosquitto.org/download/)
mosquitto has been installed with a default configuration file.
You can make changes to the configuration by editing:
    /usr/local/etc/mosquitto/mosquitto.conf

To have launchd start mosquitto now and restart at login:

```bash
  brew services start mosquitto
```

Stop `mosquitoo`

```bash
brew services stop mosquitto
```

Or, if you don't want/need a background service you can just run:
  mosquitto -c /usr/local/etc/mosquitto/mosquitto.conf