#!/bin/bash

if test $# -ge 1; then
    if test $1 = '-a'; then
        cd themes/cactus
        source update.sh
 	    cd -
    	return 0
    fi 
fi

git add -A
git commit -m "Update posts"
git push origin master

hexo deploy -g
