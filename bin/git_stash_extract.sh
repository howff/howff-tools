#!/bin/bash

git stash list | awk -F: '{print$1}' | while read stash_name; do
	mkdir -p "$stash_name"
	old_cwd=`pwd`
	cd "$stash_name"
	    git stash show "$stash_name" | grep '|' | awk -F'|' '{print$1}' | while read filename; do
	    	mkdir -p "`dirname $filename`"
	    	git show "${stash_name}:${filename}" > "$filename"
	    done
	cd "$old_cwd"
done