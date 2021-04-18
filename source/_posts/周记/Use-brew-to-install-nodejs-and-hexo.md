---
title: Use homebrew to install nodejs and hexo
date: 2021-04-18 11:13:43
tags:
- weekly
---

## Install nodejs through homebrew

```bash
brew install node
```

But you may get an error like below:

```bash
myusername@c126h060:~$ brew link node
Linking /usr/local/Cellar/node/0.12.6... 
Error: Could not symlink share/systemtap/tapset/node.stp
Target /usr/local/share/systemtap/tapset/node.stp
already exists. You may want to remove it:
  rm '/usr/local/share/systemtap/tapset/node.stp'

To force the link and overwrite all conflicting files:
  brew link --overwrite node

To list all files that would be deleted:
  brew link --overwrite --dry-run node

```

That's because you don't have the writable permission of the path `/usr/local/share/systemtap`, you can use the below command to permit it.

```bash
chown -R <yourusername>:<yourgroupname> systemtap
```
If you don't know the `yourusername`, you can use the command `whoami` to get it. The `yourgroupname` is usually **staff**. 

## Install hexo to deploy my blog

### Clone the blog repository

```bash
git clone --recurse-submodules https://github.com/SSBun/blog.git 
```
The option `--recurse-submodules` is used to clone the blog's theme repository. You can find the file `.gitmodules` in the blog directory. It's used to manage the submodules for the main git repository.

> If you forget to add the option `--recursive-submodules` when cloning the repository, you can run the two commands to fix it.

The first:
```
git submodule init
```

The seconds:
```
git pull --recurse-submodules
```