#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
src='https://github.com/EnlightenedDoge/linux-configs.git'
IFS='/' read -ra repo <<< $src
repo="${repo[-1]}"
#get name of github repo to use in path
repo="${repo:0:(-4)}"

#where the git repo will be placed
dest="$HOME/Documents/"
#Where is the config file in which the path to 
#the files/direcotries to sync is stored
conf=$(SCRIPTPATH)/config/files

cd "$dest"
if [ ! -d "$repo" ]; then
    git clone $src
fi
cd $dest$repo


IFS=' '
while read -a line
do
    #support comments and '~'path-sign in config file
    if [ "${line[0]:0:1}" == "~" ]; then
        line[0]="$HOME${line[0]:1}"
    elif [ "${line[0]:0:1}" == "#" ]; then
        continue
    fi
    #optional used for optional folder name to store files into 
    optional="${line[@]:1}"
    if [ ! -z "$optional" ]; then
        mkdir -p "$optional"
        line[1]="$optional/"
    fi
    cp -R "$line" ./"${line[1]}"
    
    #get file name
    IFS='/' read -ra fname <<< "${line[@]}"
    fname="${fname[@]:(-1)}"

    #check for existing git repos in copied directories
    #and delete them
    if [ ! -z "$optional" ];  then
        isgit=`find ./"$optional"/ -name ".git"`
        [ ! -z "$isgit" ]&&rm -r "$isgit"
    elif [ -d ./$fname ]; then
        isgit=`find ./$fname/ -name ".git"`
        [ ! -z "$isgit" ]&&rm -r "$isgit"
    fi
    optional=""
done < "$conf"

#create file containing all apps in the app list
ls /usr/share/applications/ > app_window_list.txt

#create files with all packages installed
pacman -Qqen > pacmanpkglist.txt
pacman -Qqem > aurpkglist.txt


git add .
git commit -m "sync `date '+%d/%m/%y-%H:%M'`"
git push
