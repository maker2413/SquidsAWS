#!/usr/bin/env bash

read -r -d '' USAGE << EOF
Usage: submodules [<options>]
Options:
-b BRANCH  use the provided branch
-a         add submodules from .gitmodules
-i         initialize each submodule
-m         checkout master for each submodule
-h         show this help menu
EOF

OPTIONS='b:aimh'
BRANCH='master'

while getopts $OPTIONS option
do
  case $option in
    b) BRANCH=$OPTARG
       ;;
    a) ADD=true
       ;;
    i) git submodule init && git submodule update
       ;;
    m) git submodule foreach git checkout master
       ;;
    h) printf "$USAGE" && exit 2
       ;;
    *) printf "$USAGE" && exit 1
       ;;
  esac
done

shift $(($OPTIND - 1))

if [ "$ADD" == true ]; then
  git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
    while read path_key path
    do
      url_key=$(echo $path_key | sed 's/\.path/.url/')
      url=$(git config -f .gitmodules --get "$url_key")
      if [ ! -d "./$path" ]; then
        git submodule add $url $path
      fi
    done
fi

git submodule foreach git pull origin $BRANCH
