#!/bin/bash

function repo() {
  case $1 in
    cd )
      repo="$(ghq list | sed -e 's@^github.com/@@' | fzf -1 --query=$2)"
      [ -z "$repo" ] && return
      cd "$(ghq list --full-path --exact "$repo")"
      ;;
  
    create )
      result=$(\ghq "$@")
      echo $result
      dir=$(echo -n $result | tail -1)
      [ -e "$dir" ] && cd "$dir"
      ;;
  
    rm )
      repo="$(ghq list | sed -e 's@^github.com/@@' | fzf -1 --query=$2)"
      [ -z "$repo" ] && return
      echo -n "remove ${repo}? (y/N): "
      read yn
      case yn in [yY]*) ;; *) echo 'abort.'; return ;; esac
      rm -rf "$(ghq list --full-path --exact "$repo")"
      ;;
  
    get )
      shift
      \ghq get -p "$@"
      [ $? = 0 ] || return 1
      repo="$(ghq list --full-path --exact ${@:$#:1})"
      cd $repo
      ;;
  
    * )
      \ghq "$@"
      ;;
  esac
}