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

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200525174425.png)

## 连接 WiFi

通过 MicroPython 连接 WiFi 是一件非常简单的事情，Python 用起来要比 C/C++ 和 AT 命令简单的多。

首先我们需要引入网络库 `network`，它提供了连接网络的功能。在 `STA_IF` 模式下允许我们作为终端连接其他的 WiFi

```Python
import network

wlan = network.WLAN(network.STA_IF) # create station interface
wlan.active(True)       # activate the interface
wlan.scan()             # scan for access points
wlan.isconnected()      # check if the station is connected to an AP
wlan.connect('essid', 'password') # connect to an AP
wlan.config('mac')      # get the interface's MAC adddress
wlan.ifconfig()         # get the interface's IP/netmask/gw/DNS addresses
```

而在 `AT_IF` 模式下，则是我们作为 WiFi 热点，允许其他人连接我们。

```Python
import network

ap = network.WLAN(network.AP_IF) # create access-point interface
ap.active(True)         # activate the interface
ap.config(essid='ESP-AP') # set the ESSID of the access point
```

官方提供了一个连接 WiFi 的常用代码，首先确认是否已经连接了 WiFi，如果没有的话，就会尝试连接 WiFi，不停的等待，知道连接 WiFi 成功

```Python
def do_connect():
    import network
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    if not wlan.isconnected():
        print('connecting to network...')
        wlan.connect('essid', 'password')
        while not wlan.isconnected():
            pass
    print('network config:', wlan.ifconfig())
```

有时候我们的设备可能并不在一个地方，当环境发生改变时，我们就需要重新设置 WiFi 连接，我是预设了几个可能的 WiFi，当移动设备的时候，连接 WiFi 失败以后可以重试其他的 WiFi：

```Python
import network
import time

def connect_wifi():
    print("")
    retry_times = 10
    wifis = {"No,thankyou-2": "beijing_newhome_11.3", "SSBun": "Bz123456"}
    wifi = network.WLAN(network.STA_IF)
    wifi.active(True)
    while not wifi.isconnected():
        for ssid, password in wifis.items():
            print("ready connect to wifi: " + ssid)
            wifi.connect(ssid, password)
            retry = retry_times
            success = True
            while not wifi.isconnected():
                retry -= 1
                time.sleep(1)
                print("...")
                if retry <= 0:
                    success = False
                    break
            if success:
                print("connect WiFi:" + ssid + " success")
                break
            else:
                print("connnect WiFi:" + ssid + " failure")
    print(wifi.ifconfig())
    return wifi
```

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

### 安装 umqtt

想要连接 mqtt 服务，我们需要安装 Python 库 `micropython-umqtt.simple`，在此之前我们需要先连接网络，然后进入 repl 环境，执行以下代码安装

```bash
>>> import upip
>>> upip.install('micropython-umqtt.simple')
```

### MQTT 监听

```Python
import time
from umqtt.simple import MQTTClient

# Publish test messages e.g. with:
# mosquitto_pub -t foo_topic -m hello

# Received messages from subscriptions will be delivered to this callback
def sub_cb(topic, msg):
    print((topic, msg))

def main(server="iot.eclipse.org"):   # test server : iot.eclipse.org
    c = MQTTClient("RT-Thread", server)
    c.set_callback(sub_cb)
    c.connect()
    c.subscribe(b"foo_topic")         # subscribe foo_topic tipic
    while True:
        if True:
            # Blocking wait for message
            c.wait_msg()
        else:
            # Non-blocking wait for message
            c.check_msg()
            # Then need to sleep to avoid 100% CPU usage (in a real
            # app other useful actions would be performed instead)
            time.sleep(1)

    c.disconnect()

if __name__ == "__main__":
    main()
```

### MQTT 发布

```Python
from umqtt.simple import MQTTClient

# Test reception e.g. with:
# mosquitto_sub -t foo_topic

def main(server="iot.eclipse.org"):
    c = MQTTClient("SummerGift", server)
    c.connect()
    c.publish(b"foo_topic", b"Hello RT-Thread !!!")
    c.disconnect()

if __name__ == "__main__":
    main()
```

### 实际使用示例

```Python
from machine import Pin
import uasyncio as asyncio
from umqtt.simple import MQTTClient

CLIENT_ID = 'ssbun_home_switch_1'
SERVER = 'mqtt.server'
SERVER_PORT = 1883

TOPIC_SWITCH_1 = b'ssbun_switch_1'

# pin2 控制 ESP8266 自带的那个蓝色 led
led = Pin(2, Pin.OUT)

def mqtt_callback(topic, msg):
    # `topic` 接收到的主题
    # `msg` 主题下更新的信息
    msg = msg.lower()
    print(msg)
    if topic == TOPIC_SWITCH_1:
        if msg == b"on":
            # 开启
            led.value(0)
        else:
            # 关闭
            led.value(1)

async def check_message(mqtt):    
    while True:
        # 检查主题是否有更新，会调用 `mqtt_callback`
        mqtt.check_msg()
        # 休眠 1s 再检查
        await asyncio.sleep(1)

async def ping_server(mqtt):
    while True:
        # ping mqtt 服务器保持连接
        mqtt.ping()
        print("ping server ...")
        await asyncio.sleep(30)

def main():
    # 初始化 mqtt 客户端
    # `60` 是指在一次通信后，保持连接 60s 的时间，如果超过这个时间没有和服务器通信
    # 服务器会认为连接已经断开，这里我们每 30s 钟 ping 一下服务器保持连接
    mqtt = MQTTClient(CLIENT_ID, SERVER, SERVER_PORT, "user", "password", 60)
    # 设置回调
    mqtt.set_callback(mqtt_callback)
    # 连接服务器
    mqtt.connect()
    # 订阅主题
    mqtt.subscribe(TOPIC_SWITCH_1)

    # uasyncio 是 micropython 下的多线程工具
    loop = asyncio.get_event_loop()
    # 开始监听
    loop.create_task(check_message(mqtt))
    # 每 30s ping 一下服务器
    loop.create_task(ping_server(mqtt))
    loop.run_forever()

if __name__ == "__main__":
    main()
```