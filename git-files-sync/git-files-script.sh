#git-files-sync copys and automatically pushes important configuration files from the config file to the supplied git remote.
#    Copyright (C) 2022  EnlightenedDoge

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
conf="$SCRIPTPATH"/config/files

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
