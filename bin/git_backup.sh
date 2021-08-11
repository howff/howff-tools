#!/bin/bash

now=`date +%Y%m%d-%H%M%S`
backupdir="${HOME}/tmp"

find_git_root()
{
  git_root="`pwd`"
  while true; do
    if [ -d "${git_root}/.git" ]; then
      return
    fi
    git_root=`dirname "$git_root"`
    if [ "$git_root" == "/" ]; then echo "No .git directory found"; break; fi
  done
}

find_git_root
reponame=`basename "$git_root"`
backupfile="$backupdir/git_backup_${reponame}_${now}.tar"

cd "$git_root"
git status | sed 's/modified: //' | while read line; do
  #printf "!${line}!\n"
  if [ -f "$line" ]; then
    tar rvf "$backupfile" "$line"
  fi
done
