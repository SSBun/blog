---
title: 部署 Hexo 博客到 VPS
date: 2019-12-30 17:41:54
tags:
---
## 创建 Hexo 项目
### 安装 Hexo 依赖
**首先**你需要安装以下应用程序[官方教程](https://hexo.io/zh-cn/docs/)：
- [Node.js](http://nodejs.org/) (Node.js 版本需不低于 8.10，建议使用 Node.js 10.0 及以上版本)
- [Git](http://git-scm.com/)

 在 Mac 上安装软件，通常使用 [Homebrew](https://brew.sh/index_zh-cn)，安装命令如下：
 ```bash
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### 安装 Hexo
使用 npm 安装 Hexo
```bash
npm install -g hexo-cli
```
然后执行如下代码查看 Hexo 版本
```
hexo -v
```
### 创建 Hexo 项目
首先创建一个 Hexo 项目
```bash
hexo init <folder>
cd <folder>
npm install
```
**关于 Hexo 的使用大家可以查看[官方文档](https://hexo.io/zh-cn/docs/setup)**

## 配置 VPS

我这里使用的是阿里云服务器，使用 root 用户登录。

### Nginx
#### 安装 Nginx
```bash
apt-get update
apt-get install nginx
```

#### 配置 Nginx
**`/root/blog` 用于存放网站的静态文件**
```bash
mkdir /root/blog
```
**创建 blog 的 Nginx 配置**
```bash
vi /etc/nginx/conf.d/blog.conf
```
**配置 80 端口及博客路径**
```json
server {
    listen 80;
    root /root/blog;
}
```
> 如果后续发现部署完毕后通过 80 端口访问一直显示 Nginx 欢迎页面, 通过设置 `/etc/nginx/sites-enables/` 中 `default` 的配置，把默认的 Nginx 欢迎页面调整到其他端口就行了

#### 重启 Nginx
```bash
sudo service nginx restart
```

### Git Hooks
#### 安装 Git
```bash
apt-get install git-core
```
#### 创建 Git 库
创建一个 git 的仓库，博客静态文件将通过 Hexo 部署 `push` 到此 git 库当中
```bash
mkdir /root/blog.git
cd /root/blog.git
git init --bare
```
#### Hooks 监听代码提交
```bash
vim /root/blog.git/hooks/post-receive
# 打开可执行权限
chmod +x /root/blog.git/hooks/post-receive
```
脚本仅仅把 `/root/blog` 替换为 `git` 库中的内容
```bash
#!/bin/bash

rm -rf /root/blog
git clone /root/blog.git /root/blog
```
## 部署及更新 blog

#### 配置 `_config.yml` 文件
```yml
.
.
.
# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: 'git'
  repo: root@80.23.43.19:blog.git
```

#### 部署
```bash
hexo deploy
```
等待部署完毕，输入的你的 ip 地址或域名就能看见 Hexo 为你生成的静态博客了。
