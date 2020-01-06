---
title: Deploy Flask by Docker
date: 2019-11-22 17:41:54
tags:
---

## Docker 基本操作

- `docker ps`  查看正在执行的容器
- `docker ps -a` 查看所有容器，包括已经结束的
- `docker images` 查看本地安装的镜像
- `docker run ubuntu:18.04` or `docker run ubuntu:latest` 运行一个容器，使用指定的镜像和版本，如果这个镜像本地没有，就会在 Docker 的镜像云上根据名字和版本进行搜索下载
- `docker inspect xxxxx` 用来查看容器的内部数据 `xxxxx`既可以是容器 ID 也可以是容器名字
- `docker rm xxxxx` 删除容器 `docker rm $(docker ps -aq)` 可以删除所有容器
- `docker rmi xxxxx` 删除镜像 `docker rmi $(docker images -q)` 可以删除所有镜像
- `docker run -it -p 8080:80 -v /tmp/web:/var/www/html ubuntu:latest bash` `-i` 表示要和容器交互 `-t` 表示创建一个终端 `-p 8080:80` 表示将本机的8080端口映射到容器的80端口上, `-v /tmp/web:/bar/www/html` 表示将主机路径/tmp/web 映射到容器的 /bar/www/html路径上 `bash` 是开启容器后执行的命令
- `docker start -i xxxxxx` 重新启动一个已经退出的容器
- `docker stop xxxxx` 关闭一个在后台运行的容器

了解了基本操作以后，然后就是了解如何构建我们自己的镜像了。可以发现根据基础的镜像构建完成后，我们可能会在容器里面添加各种各样的工具和环境，我们可以通过 Docker 来提交完善后的容器为一个新的镜像，这样我们下次再使用这个镜像时就不需要进行重复的操作了
- 首先通过 `docker ps -a` 来查看我们刚刚运行过的容器
- 你可以通过 `docker diff xxxxx` 来查看容器文件的修改
- 然后通过 `docker commit -a "author name" -m "commit message" xxxxxx imageName:0.1.0` 来提交修改，这里 `xxxxx` 是你要提交容器的 ID，而 `imageNmae` 是镜像名字，当然为了不与别人重名，建议使用 `author/name` 的形式加上你自己的专属前缀，而后面的 `0.1.0` 这是你构建的镜像的版本号
完成了上面的步骤以后，你就能通过 `docker images` 来查看自己创建的镜像了

## 关于 Nginx 在 Docker 中的运行
开启一个已经安装了 Nginx 的镜像时并自动执行 nginx 时，容器会直接退出，这是由于 nginx 会默认启动两类进程，首先启动的是作为管理调度的master process，它继续生成实际处理HTTP请求的worker process。默认情况下，master process是一个守护进程，它启动之后，就会断掉和自己的父进程之间的关联，于是Docker就跟踪不到了，进而容器也就会退出了。因此，解决的办法，就是让Nginx的master process不要以守护进程的方式启动，而是以普通模式启动就好了。为此，我们得修改下 Nginx 的配置文件。
开启一个可交互的 nginx 容器，然后输入 `echo "daemon off;" >> /etc/nginx/nginx.conf` 关掉守护进程模式。最好将此容器重新提交为一个新的镜像，下次使用就可以直接开启了。

## 自动化构建镜像
上面都是我们手动打造一个镜像，当我们需要在其他的服务器上部署相同的镜像或是需要分享给别人我们的镜像时，如果能通过一个脚本文件直接分享岂不美哉。而 Docker 正为我们提供了这样的工具，这就是一个 `Dockerfile` 文件，`Dockerfile` 并不是唯一的脚本名字，只是 Docker 默认的脚本名字，你可以在运行时指定脚本文件，或者让 Docker 在指定目录下自动寻找 `Dockerfile` 文件。

```Dockerfile
FROM ubuntu:latest

LABEL maintainer="SSBun <caishilin@yahoo.com>"

RUN apt-get update && apt-get install nginx -y \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && echo "daemon off;" >> /etc/nginx/nginx.conf

CMD ["nginx"]
```

- `FROM` 是构建此镜像的基础镜像，至少你要先运行一个系统吧
- `LABEL` 可以用来定义一些容器的数据，这里用来说明镜像的作者
- `RUN` 是容器被构建时运行的命令，这里使用 `&&` 将多个命令写为一个，可以降低镜像的大小，我们尽量少的使用 `RUN`
- `CMD` 则是启动容器后运行的 bash 命令

我们运行 `docker build -t ssbun/nginx:0.1.2 .` 就会构建一个镜像，并启动一个容器
- 我们可以通过 `-f filename` 来指定脚本名字，或者让他在当前目录查找 `Dcokerfile`  文件
- `-t` 用来设置新镜像的名字和版本
- 最后的`.`用于设置构建镜像时的上下文

接下来我们可以将我们构建的镜像提交到云上，先用 `docker images` 查看你的镜像 id 然后通过 `docker push ssbun/nginx:0.1.2` 来上传你的镜像，别忘了先登录你的 docker 账号, 然后再其他的环境上你可以通过`docker pull ssbun/nginx:0.1.2` 来把镜像再拉取下来

上传镜像中可能遇见 `denied: requested access to the resource is denied` 解决此办法首先
- 调用 `docker login` 确定已经登录了
- 然后上传的镜像名字必须是 `account/xxxx`  的样式，必须用你的docker 用户名作为前缀
- 你可以使用 `docker tag firstimage YOUR_DOCKERHUB_NAME/firstimage` 来修改镜像名字


## 创建一个 Flask 镜像
- 先开启一个交互式的纯 ubuntu 容器
- 执行 `apt update && apt install software-properties-common` 更新安装包列表和安装必要的包
- 再执行 `sudo add-apt-repository ppa:deadsnakes/ppa & apt install python3.7`
- 最后安装成功后用 `python --version` 查看版本

安装 pip
- `apt install python3-pip`

安装 Gunicorn
- `pip3 install gunicorn`

安装 Flask
- `pip3 install Flask`
  
安装完成后，退出容器然后提交成一个 flask 镜像

## 代码部署在哪里
我们通过将项目代码利用 Volumn 挂载在容器上
`docker run --name=myapp -it -p 8080:8000 -v /tmp/server:/server -w /server  ssbun/flask:0.1.0 gunicorn -w 4 -b 0.0.0.0:8000 myapp:app`

如果要使用一个 `Nginx` 作为反向代理的话，不需写 `-p 8080:8000` 把端口暴露出来，使用 `docker run --link=myapp:flask -p 80:80 -it ssbun/nginx:0.1.5` 开启一个 nginx 容器，将此容器和 `flask` 容器连接起来
-`--link=myapp:flask` `myapp` 是 flask 容器的名字，而`flask`是指 flask 容器连接在 nginx 中的名字



## 其他的代码
```
FROM ubuntu:latest

LABEL maintainer="SSBun <caishilin@yahoo.com>"

RUN apt-get update && apt-get install nginx -y \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && echo "daemon off;" >> /etc/nginx/nginx.conf

ADD default /etc/nginx/sites-available/default

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

CMD ["nginx"]
```

```
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;

    index index.html index.htm index.nginx-debian.html;

    server_name localhost;

    try_files $uri @proxy;
    location @proxy {
        proxy_pass http://flask:8080;
        proxy_pass_header Server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 5s;
        proxy_read_timeout 10s;
    }
}
```