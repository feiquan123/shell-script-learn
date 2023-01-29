#!/bin/bash

# cd --- 改变目录时更新 PS1 

cd () {
	command cd "$@"
	x=$(pwd)
	PS1="${x##*/} \$ "
}