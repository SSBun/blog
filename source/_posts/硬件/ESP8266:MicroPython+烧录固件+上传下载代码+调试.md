---
title: ESP8266:MicroPython+烧录固件+上传下载代码+调试
date: 2020-05-21 10:28:42
tags:
- ESP8266
- MicroPython
categories:
- hardware
---

## 安装 MicroPython 到 ESP8266

### 硬件准备

1. 一片 `ESP8266`， 它的 `flash size` 最低要求为 `1MB`
2. 串口工具，例如 `CH340`。如果你使用的是类似 `NodeMCU` 的开发板，它自带了串口芯片可以直接使用

### 下载 MicroPython 固件

[MicroPython 官方下载地址](http://micropython.org/download/#esp8266)，下载页面可以选择芯片类型，这里选择 ESP8266。 版本推荐使用 `Stable firmware` 稳定版, 如果你想使用更多的特性，可以尝试一下 `Daily firmware` 版本。

### 烧录 MicroPython 固件

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

## 连接 ESP826

上述步骤完成以后，`ESP8266` 内部就运行了一个精简版本的 Pyton 环境, 我们想要连接它有两种方式：**串口调试**和**WebREPL**。

### 通过串口连接 ESP8266

使用 PlatformIO 的串口监视器，我们可以连接 `ESP8266`, 然后再窗口中会显示 `>>>`, 表示你已经进入到了 `Python` 环境当中。

### 使用 WebREPL 连接 ESP8266

首先我们下载 [WebREPL 工具](https://github.com/micropython/webrepl) 到本地。`WebREPL` 提供了一个通过 WiFi 远程调试的功能，我们可以远程更新和下载 flash 中的文件。

ESP8266 在烧录完成后，会自动开启一个 WiFi 站点，名字为 `MicroPython-xxxxxx`, 密码是 `micropythoN`。在进入 `WebREPL` 之前我们需要提前进行设置，通过串口工具连接进去，执行以后命令会让你设置连接密码。

```python
import webrepl_setup
```

连接的时候注意要连接上 `ESP8266` 的 WiFi，才能同步文件成功
然后连接 ESP8266 的 WiFi，点击 connect 进行连接，输入密码，连接成功以后，就可以在线执行命令或更改和提交文件了。

### 通过 [mpfshell](https://github.com/wendlers/mpfshell) 连接 ESP8266

通过串口进入 repl 环境中，上传代码和查看文件都非常的麻烦，而通过插件同步文件的时候，会同步所有的文件，这样会导致一些在 ESP8266 上调用 `upip` 安装的库被覆盖掉，并且还无法下载文件。

`mpfshell` 是提供一个类似 shell 的访问模式，你可以在这里调用 `ls`,`cd`,`rm` 等常用的命令管理目录，并提供了 `put`，`get` 命令用来上传和下载文件。

我们可以通过 `sudo pip install mpfshell` 安装 `mpfshell`, 下面是我用到的一些常用命令

| command                 | description                                                |
|-------------------------|------------------------------------------------------------|
| **mpfs**                | Start the shell                                            |
| **open ttyUSB0**        | Sonnect via serial                                         |
| **ls**                  | list the file                                              |
| **put boot.py**         | Upload file boot.py form local to the board                |
| **put boot.py main.py** | Upload boot.py file to the board and use another file name |
| **mput .*\\.py**        | Upload all files that match a regular expression           |
| **get boot.py**         | Download boot.py to local                                  |
| **mget .*\\.py**        | Download all files that match a regular expression         |
| **rm boot.py**          | Remove remote file boot.py                                 |
| **mrm test.*\\.py**     | Remove all remote files that match a regular expression    |
| **cd lib**              | To navigate remote directories                             |
| **pwd**                 | See current directory                                      |
| **lls**                 | local filesystem                                           |
| **lcd**                 | local filesystem                                           |
| **lpwd**                | local filesystem                                           |
| **repl**                | Enter repl                                                 |
| **Ctrl + ]**            | Exit repl                                                  |


> 相关文档:
> [MicroPython for ESP8266 官方文档](http://docs.micropython.org/en/latest/esp8266/quickref.html)
> [PT-Thread (VSCode 插件)论坛](https://www.rt-thread.org/qa/forum.php)