---
title: git 中你不知道的实用技巧
date: 2018-11-16 17:23:30
tags:
- git
---

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119133639.png)

> 翻译于 [**How to become a Git expert**](https://medium.freecodecamp.org/how-to-become-a-git-expert-e7c38bf54826)

如果你在刚刚的提交中，提交了一些错误的信息，改如何处理它呢？

如果你的提交历史十分混乱，又改如何让它变得整洁一些呢？

如果你也有上述的麻烦要解决，这篇文章就是为你而写的， 这篇文章中提到了一系列进阶的git使用方法用于处理这些问题，如果学会了这些，应该就算得上是一个小git专家了吧。

如果你还不知道 git 的基本使用方法，可以[点击这里](https://www.jianshu.com/p/97946d9df5bd)通过我的博客进行了解， 了解基本的git使用方法可以帮助你更好的理解本文的内容。

## 我进行了一次错误的提交，我该怎么办呢？

### 场景一
如果你提交了一部分文件和修改，但是编写的提交信息并不能很好的描述本次提交的内容，如果你想要修改提交信息，该怎么办呢，这个时候你可以使用 `git commit --amend`

```bash
git commit --amend -m "New commit message"
```

### 场景二
如果你在这次提交中总共修改了6个文件，但是你在提交的时候却只提交了5个，这个时候你可能会想，我再提交一次，把这个文件加进去不就可以了吗。
这样的处理方法并没有什么问题，不过如果你在意一个整洁的提交历史的话，为什么不想办法，把这个文件添加到上次提交的内容里面呢？通过使用`git commit --amend`你可以做到这个效果：

```bash
git add file6
git commit --amend --no-edit
```

### 场景三
无论你在什么时候进行提交，提交记录中都会有你的名字和email信息， 通常情况下，在你第一次使用git的时候，你会进行这些全局设置，不用担心每次提交的时候都要进行处理。

这也就是说，如果有一个特殊的项目你想在在提交的时候使用一个不同的email ID。 你需要在这个项目的git中进行如下的配置：

```bash
git config user.email "your new email id"
```

假如，你忘记在这个特殊的项目里面进行email ID 的修改，然后进行了第一次提交。这个时候你可以使用`Amend` 修改你上次提交的作者。 你可以通过如下的命令来实现修改：

```bash
git commit --amend --author "Author Name <Author Email>"
```

> 特别提醒： 使用`amend`命令只能在你的本地仓库中使用，使用在远程库上会导致一些奇怪的问题

## 我的提交历史很是混乱，我改如何处理它呢？

比如说，现在你正在实现一个功能，你知道这个功能大概要十天的时间才能完成。 你从远程主分支开了一个新的分支来编写这个功能。在这十天里面不停的会有同事将其他的代码提交到远程主分支上。

为了保持你的分支代码和主分支代码是同一个进度，你需要合并远程主分支到你的分支上，如果你在最后一天进行合并，大量的修改可能会引发大量的冲突，一次性修改大量的冲突简直让人发狂。所以你决定每两天进行一次分支合并以更新代码。

每次你从远程主分支合并代码到本地分支，都会创建一个新的提交。这意味着你的本地提交历史会掺杂着非常多的合并提交记录，这会让review你代码的人感觉提交非常的混乱。

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119133939.png)

那该如何让提交历史变得更整洁呢?
这个时候就该`rebase`粉墨登场了

### 什么是 rebasing?

让我通过一个例子来进行解释。

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119134504.png)

1. 我们可以看到在 Release 分支上有3个提交记录：Rcommit1, Rcommit2 和 Rconmit3。
2. 你在 Release 分支只有一个 Rcommit1 提交的时候，创建了一个新的 Feature 分支。
3. 你随后在 Feature 分支上进行了两次提交，分别是：Fcommit1 和 Fcommit2.
4. 你的目标是将 Release 分支上的提交合并到你的 Feature 分支上。
5. 现在你可以使用`rebase`来实现它。
6. 我们假设 Release 分支的名字就是`release` 而 Feature 分支的名字就是`feature`。
7. 我们通过`rebase`进行如下指令进行处理

```
git checkout feature
git rebase release
```

### Rebasing

当你进行Rebasing的时候，你的目标时保证你的 Feature 分支能够更新到来自于 Release 分支上最新的代码。

Rebasing 尝试添加所有的提交，一个一个的添加，然后处理出现的冲突，是不是听的有些困惑？

让我通过一幅图片来给你解释。这展示了 rebasing 内部进行的实际操作。

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200119134618.png)


__Step 1__

1. 在你执行命令的一瞬间，Feature 分支就定位到 Release 分支的头部。
2. 现在 Feature 分支有三个提交记录：Rcommit1， Rcommit2 和 Rcommit3。
3. 你可能惊讶在 Fcommit1 和 Fcommit 上发生了什么。
4. 这些提交实际还在这里，在接下的步骤里将会出现。

__Step 2__

1. 现在 Git 尝试添加 Fcommit1 到 Feature 分支当中。
2. 如果在 Fcommit1 添加到 Rcommit3 之后没有发生冲突，就继续
3. 如果发生了冲突，Git 将会提示你，然后必须手动解决这些冲突。当所有的冲突被解决以后，你可以使用如下命令恢复 rebasing。

```
git add fixedfile
git rebase --continue
```

__Step 3__

1. 一旦 Fcommit1 被添加，Git 会尝试添加 Fcommit2.
2. 同样的，如果在 Fcommit2 被添加到 Fcommit1 以后没有冲突发生则 rebase 成功。
3. 如果发生了冲突，Git 会提示你，你需要手动解决这些冲突，然后重复 Step 2的方法来恢复 rebasing.
4. 当所有的 rebase 完成以后，你发现 Feature 分支上有所有的5个提交。

**要点注意：**
 
1. 无论是`Rebase` 还是 `Merge` 都是Git中强有力的工具，没有孰好孰坏之说。
2. 如果使用 `Merge` 你会多一个合并提交记录， 如果使用 `Rebase` 就不会出现一个多余的合并提交记录。
3. 最好的实践方法就是因情况而异，如果你想要从一个远程主分支合并最新的代码到你的本地分支上，你可以选择`rebase`。 如果你是要将你的本地分支重新合并会远程主分支，这个时候你可以选择 `merge`。
4. 使用 Rebase 修改提交历史可以让它看起来更整洁。但是也可能会产生一些风险，所以，我们要确保一定不要在远程分支上使用rebase，通常我们只会去写改本地分支的提交历史。
5. 如果在远程分支上使用了rebase，当其他的开发者试图从远程分支上拉取代码的时候会产生一些问题。所以重要的事情要说三遍，不要用在远程分支上，不要用在远程分支上，不要用在远程分支上。

## 恭喜你！！！

现在，你已经是一个 Git 专家了😃

在这篇文章里你学会了：

* **修改错误提交**
* **rebase**

上述都是一些特别有用的技巧和观点。接下来，让我们继续去探索 Git 世界，去学习更多实用的用法吧。

