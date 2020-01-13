#!/bin/bash

git add -A
git commit -m "Update posts"
git push origin master

hexo deploy -g
