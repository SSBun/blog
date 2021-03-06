---
title: IoT:MQTT+Mosquitto
date: 2020-05-22 12:17:55
tags:
- MQTT
- Mosquitto
categories:
- hardware
---

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200525162439.png)

> MQTT（Message Queuing Telemetry Transport）协议是重要的物联网传输协议

MQTT 作为物联网协议具有很多的优势：

- **异步消息协议**
- **面向长连接**
- **双向数据传输**
- **协议轻量级**
- **被动数据获取**

## MQTT 核心

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200525161658.png)

### Broker (MQTT 服务器)

Broker 是 MQTT 传递信息的枢纽，发布者会将信息发布到这里，而订阅者会从这里监听需要的信息。发布者和订阅者之间没有任何联系，都是通过 Broker 这个代理人来进行信息的互动。

### Topic (主题)

主题是信息类型的标记，一般情况下主题是类似于文件系统的目录结构 `assistant/light/bedroom`, 你可以把 Broker 想象成一个存放信息的大仓库，而这个主题下的信息，就是存放在 `assistant` 区，`light` 货架上的 `bedroom` 层。不过 MQTT 服务器并没有规定 topic 的规则，只要发布者和订阅者协商一致，任何字符串都可以当做主题。

### Publish (发布)、Subscribe (订阅)

发布者将要发布的信息传送给MQTT服务器的某个主题下，订阅者可以监听对应的主题并读取信息

## MQTT 信息

### 传输质量

MQTT中定义了三种传输质量（发布者和订阅者在与服务器通讯的过程中可以指定对应的质量）。

- **0**：信息仅被传输一次，对于信息是否被收到不做任何确认。
- **1**：信息可能被传输若干次，只有当信息收取者确认收到后才停止传输。
- **2**：通过额外的4次握手过程，保证信息仅被传输一次，并且接收者收到了信息。

### 信息保留

每条发布的消息可以设置成保留（Retained）——意味着MQTT服务器在将这条信息发送给对应主题的当前订阅者之后，还会保留这条信息，这样当新的订阅者连接服务器时，会收到这条消息。
信息保留机制，对于那些非频繁更新的信息比较有用，这样新的订阅者就能收到当前的状态——比如一个温度传感器，每小时发送当前温度给MQTT服务器；另一个想要获知温度的程序连接MQTT服务器时，可能需要等一个小时才能得到当前温度；当温度传感器发送的消息代有信息保留（Retain）属性时，就不会发生这种情况了。

### Will消息

客户端连接 MQTT 服务器时，可以告知服务器它有一个 Will 消息（遗嘱）—— Will 消息将在这个客户端非正常断开时被发布。
比如，一个 MQTT 的灯，可以通过Will消息告知控制端，自己已经断开连接了（OffLine）。

### 保持连接

MQTT 采用 TCP 协议作为通讯基础，TCP很容易在一方突然断电时形成另一方以为连接还有效的状态。同时，因为MQTT传输内容的性质，很可能长时间没有客户端与服务器端的实际内容通讯——简单来说，就是系统无法分辨连接已经断了还是真实没有通讯。
因此，在MQTT中有类似 ping 的机制，客户端发送 ping，服务器端进行回应。同时，在客户端与服务器端建立连接时，可以设置保持连接（KeepAlive)——约定在多少秒之内，若客户端没有任何消息（包括 ping）发送给服务器端，服务器端就认为这个连接已经断了。

### 主题通配符

在订阅消息时，订阅者订阅的主题名称可以使用通配符。MQTT协议的通配符有两个，`+` 和 `#`。
`+` 代表主题名称中的一级；`#` 代表主题名称中若干级。

例如：
a/b/+/d：可以收到主题“a/b/c/d”或者“a/b/x/d”上的消息，但不能收到“a/b/x/y/d”上的消息。
a/b/#/d：可以收到主题“a/b/c/d”、“a/b/x/d”、“a/b/x/y/d”上的消息

### 客户端认证

- MQTT服务器可以设置为允许匿名登录——这时，所有客户端不需要认证即可登录服务器。
- MQTT服务器可以设置成需要用户名密码——这时，提供正确用户名和密码的客户端可以登录服务器。
- MQTT服务器可以设置成加密通讯，并且需要客户端证书——这时，提供能通过验证的证书文件的客户端可以登录服务器（用户名为证书信息中的CN，Common Name）

## MQTT 服务

### [Mosquitto](https://mosquitto.org/)

Eclipse Mosquitto 是实现 MQTT 协议版本5.0、3.1.1 和 3.1 的开源消息代理（经EPL / EDL许可）。 Mosquitto 非常的轻巧，在从低功耗单板计算机到完整服务器的所有设备上都可以使用。Mosquitto 项目还提供了一个 C 库， 用于实现 MQTT 客户端。你可以方便的使用命令行 mosquitto_pub 和 mosquitto_sub 来发布、订阅主题。

#### 下载安装

[Mosquitto download](https://mosquitto.org/download/)

#### 配置

Mosquitto 服务的配置文件为 **/etc/mosquitto/mosquitto.conf**，但一般情况下，我们不会去修改这个文件，而是将需要配置的内容新建文件保存在 /etc/mosquitto/conf.d/ 目录下。
在缺省情况下，Mosquitto 服务是允许匿名用户发布和订阅信息的，我们需要将其改成用户通过用户名和密码，以保证安全。
创建文件 /etc/mosquitto/passwd，并增加用户 ssbun，设置密码

```bash
sudo mosquitto_passwd -c /etc/mosquitto/passwd ssbun
```

> 如果没有 `-c` 参数，代表不新建文件，而是在原文件中增加新的用户，或修改原来用户的密码。

新建文件 **/etc/mosquitto/conf.d/allow.conf**，内容为：

allow_anonymous false
password_file /etc/mosquitto/passwd

更多的配置，可以参考[官方文档](https://mosquitto.org/man/mosquitto-conf-5.html)

#### 调试使用

**`mosquitto_sub`** - 监听指定主题下的消息

| 常用参数 | 作用                                          |
|:---------:|:---------------------------------------------|
| -h       | 连接的服务器                                  |
| -p       | 连接的端口号（缺省为1883）                      |
| -u       | 用户名                                        |
| -P       | 密码（注意P为大写）                             |
| -V       | 协议版本号（注意V为大写）                       |
| -t       | 主题名称，可以使用通配符#和+                   |
| -v       | 输出主题+监听到的消息（否则仅输出监听到的消息） |

例如，以下命令使用用户 `pi`、密码 `123`，连接到 `10.0.1.105` 的 `1883` 端口，监听所有的主题，打印出对应的内容：

```bash
mosquitto_sub -t "#" -v -u pi -P 123 -h 10.0.1.105
```

**`mosquitto_pub`** - 向指定的主题发送消息

| 常用参数 | 作用                     |
|----------|------------------------|
| -h       | 连接的服务器             |
| -p       | 连接的端口号（缺省为1883） |
| -u       | 用户名                   |
| -P       | 密码（注意P为大写）        |
| -V       | 协议版本号（注意V为大写）  |
| -t       | 主题名称                 |
| -m       | 消息体                   |

例如，以下命令在 `hello/world` 主题位置发布消息 Hello, World

```bash
mosquitto_pub -t hello/world -m "Hello, World" -h 10.0.1.105 -u pi -P 123
```
