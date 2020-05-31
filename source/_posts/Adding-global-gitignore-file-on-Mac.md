---
title: Adding global .gitignore file on Mac
date: 2020-05-31 21:35:01
tags:
categories:
- tips
---
In order to start using it, go through these steps:

1. Open Terminal.
2. Run touch `~/.gitignore_global` - this will create global .gitignore file in your home directory.
3. Add some values that you would like to always ignore. For example, you could use this file.
4. Run `git config --global core.excludesfile ~/.gitignore_global`. According to this page at git-scm.com this command will make all the patterns from `~/.gitignore_global` ignored in all situations.