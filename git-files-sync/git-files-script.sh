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
    
    echo "${line}"
    echo "$optional"
    IFS='/' read -ra fname <<< "${line[@]}"
    fname="${fname[@]:(-1)}"
    echo $fname
    if [ ! -z "$optional" ];  then
        isgit=`find ./"$optional"/ -name ".git"`
        echo "$isgit"
        [ ! -z "$isgit" ]&&rm -r "$isgit"
    elif [ -d ./$fname ]; then
        isgit=`find ./$fname/ -name ".git"`
        echo $fname"\n$isgit"
        [ ! -z "$isgit" ]&&rm -r "$isgit"
    fi
    optional=""
done < "$conf"

git add .
git commit -m "sync `date '+%d/%m/%y-%H:%M'`"
git push
