#!/bin/bash

mode=$(grep -o '#ControllerMode = [^ ,]\+' <<< `grep '#ControllerMode = ' /etc/bluetooth/main.conf`|awk '{print $3}')
if [ "$2" == "" ]; then
echo "Current mode: $mode $2"
fi

if [ "$EUID" != 0 ]; then
    sudo "$0" "$1" "0"
    exit $?
fi

read -r -p "Are you sure? [y/N] " response
if [ -z "$response" ] || [[ "$response" =~ [^Yy] ]]; then
	echo "Terminating..."
	exit 0
fi
if [ "$mode" == "bredr" ]; then
	sed -i 's/#ControllerMode = bredr/#ControllerMode = dual/g' /etc/bluetooth/main.conf
	echo "switched to dual"
elif [ "$mode" == "dual" ]; then
	sed -i 's/#ControllerMode = dual/#ControllerMode = bredr/g' /etc/bluetooth/main.conf
	echo "switched to bredr"
else
	echo "Error reading file, no 'ControllerMode' was recognised"
fi
service bluetooth restart