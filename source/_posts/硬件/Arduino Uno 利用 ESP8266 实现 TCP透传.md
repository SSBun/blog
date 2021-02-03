---
title: Arduino Uno 利用 ESP8266 实现 TCP透传
date: 2019-11-24 17:41:54
tags:
- Arduino
- ESP8266
- TCP
categories:
- hardware
marks:
- ESP8266
- Arduino
---

利用 Arduino Uno 的软串口和 ESP8266 进行通信，为 Arduion Uno 提供连接 WiFi 的能力。

## ESP8266 和 Arduino Uno 的调试
首先我们调试一下软串口和ESP8266是否通信正常，并设置正确的波特率，现阶段我们购买的 ESP8266 多为 12e 或是 12s之类的版本，拥有 4MB 的 Flash，默认的波特率应该是 115200, 而 Arduino Uno 的软串口在高波特率的情况下通信并不稳定，建议降低到 9600 和 Arduino Uno 相同的波特率。

你可以利用 USB-TTL 工具通过 AT 指令 `AT+UART_DEF=9600` 来修改波特率，修改完毕以后切换串口工具的波特率如果发送`AT`指令成功就是修改完成了。
如果你没有 USB 转串口工具，也可以将ESP8266插到 Arduino Uno 的串口上利用 Arduino Uno 来进行串口通信，接下来就是Arduino Uno 的软串口调试

```C++
#include <SoftwareSerial.h>
 
SoftwareSerial mySerial(3, 2); // RX, TX
 
void setup()
{
// Open serial communications and wait for port to open:
Serial.begin(9600); 
// set the data rate for the SoftwareSerial port
mySerial.begin(9600);
}
 
void loop() // run over and over
{
    
    if (mySerial.available()) {
        Serial.write(mySerial.read());
    }    
    if (Serial.available()) {
        mySerial.write(Serial.read());
    }    
}
```
上面的代码中我们将 `引脚3,2`设置为软串口，然后互相传递 Arduino Uno 的串口和软串口之间的数据，烧录代码，然后执行 AT 命令，就相当于直接与 ESP8266 通信，如果返回正常，软串口就没有什么问题了。

## 发起一个完整的 TCP 透传
1. 然后设置当前的 WiFi 模式为 `AT+CWMODE_DEF=1`  站点模式
2. 用 `AT+CWJAP_DEF="SSID","PASS_WORD"` 连接 WiFi，使用`AT+CWJAP_DEF` 会将连接 AP 的设置保存到 Flash
3. 用 `AT+CWAUTOCONN=1` 设置 ESP8266 在断电重启以后自动连接保存的 AP
4. `AT+CIPMODE=1` 设置为透传模式
5. 然后开始建立 TCP 连接 `AT+CIPSTART="TCP","192.168.80.3",5000`
    - `TCP` 是建立的连接模式，有 `UDP`, `TCP`    
    - `192.168.80.3` 请求的服务器 ip 地址
    - `5000` 是端口
6. 接下来就是发送数据了，先调用`AT+CIPSEND`，然后等待返回 `>`,
7. 然后就开始输入请求的内容 `GET /index  HTTP/1.1\r\n\r\n`，等待服务器返回数据（注意要连续两次`\r\n`才能发出消息）
8. 获取服务器的数据后，此处 TCP 连接不会断开，可以重复步骤 **7** 来发送数据接收数据
9. 发送`+++`来退出透传模式, 不要换行

> 注意在透传模式下，如果此处 TCP 请求没有完成，下次打开会自动连接继续进行数据传输，如果希望重新上电以后不自动进行透传，可以在 `setup()` 方法里面用 `+++` 先退出透传模式，防止后续的 `AT` 命令失效。

## 需要使用的基础 AT 指令

- `AT` 查看AT 命令是否可用

- `AT+RST` 重启模块

- `AT+GMR` 查询版本信息

- `AT+RESTORE` 恢复出厂设置

- `AT+CWMODE_CUR` 设置当前 Wi-Fi 模式
  - `1`: station 站点就是连接网络的终端，手机连接 WiFi 路由，手机就是 station
  - `2`:softAP WiFi路由就是 AP (Access Point)， 而 sfotAP 就是模拟一个 AP
  - `3`: softAP + station

- `AT+CWMODE_DEF` 设置 Wi-Fi 模式并保存到 Flash

- `AT+CWJAP_CUR`临时链接 AP `AT+CWJAP_CUR="SSID","PASS_WORD"`

- `AT+CWJAP_DEF` 链接 AP 保存到 Flash

- `AT+CWAUTOCONN` 上电自动链接 AP

- `AT+CIPMODE=1` 设置为透传模式

- `AT+CIPSTART="TCP","192.168.50.114",8080` 创建 TCP 链接

- `AT+CIPCLOSE` 关闭链接
- `AT+CIPSTATUS` 查看网络连接信息
  - 2: 已经连接 AP，获取 IP 地址
  - 3: 已经建立 TCP 或 UDP 传输
  - 4: 断开网络连接
  - 5: 未连接 AP