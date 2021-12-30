#!/bin/bash

mode=$(grep -o '#ControllerMode = [^ ,]\+' <<< `grep '#ControllerMode = ' /etc/bluetooth/main.conf`|awk '{print $3}')
if [ "$2" == "" ]; then
	echo "Current mode: $mode"
	if [ "$mode" == "bredr" ]; then
		echo "Single channel and microphone are supported"
	else
		echo "Dual channels are supported but without microphone"
	fi
	
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
	echo "switched to dual: dual channel, no headset microphone"
elif [ "$mode" == "dual" ]; then
	sed -i 's/#ControllerMode = dual/#ControllerMode = bredr/g' /etc/bluetooth/main.conf
	echo "switched to bredr: single channel"
else
	echo "Error reading file, no 'ControllerMode' was recognised"
fi
service bluetooth restart

read -n 1 -s -r -p "Press any key to continue"
