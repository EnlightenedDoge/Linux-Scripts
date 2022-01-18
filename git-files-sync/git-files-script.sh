#!/bin/bash
src='https://github.com/EnlightenedDoge/linux-configs.git'
IFS='/' read -ra repo <<< $src
repo="${repo[-1]}"
repo="${repo:0:(-4)}"

dest="$HOME/Documents/"
conf=$(pwd)/config/files
cd "$dest"
if [ ! -d "$repo" ]; then
    git clone $src
fi
cd $dest$repo
IFS=' '
while read -a line
do
    if [ "${line[0]:0:1}" == "~" ]; then
        line[0]="$HOME${line[0]:1}"
    fi
    optional="${line[@]:1}"
    if [ ! -z "$optional" ]; then
        mkdir -p "$optional"
        line[1]="$optional/"
    fi
    cp -R "$line" ./"${line[1]}"
done < "$conf"

git add .
git commit -m "sync `date '+%d/%m/%y-%H:%M'`"
git push
