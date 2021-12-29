#!/bin/bash

mode=$(grep -o '#ControllerMode = [^ ,]\+' <<< `grep '#ControllerMode = ' /etc/bluetooth/main.conf`|awk '{print $3}')
echo "$mode"
if [ "$mode" == "bredr" ]; then
	sed -i 's/#ControllerMode = bredr/#ControllerMode = dual/g' /etc/bluetooth/main.conf
	echo "switched to dual"
elif [ "$mode" == "dual" ]; then
	sed -i 's/#ControllerMode = dual/#ControllerMode = bredr/g' /etc/bluetooth/main.conf
	echo "switched to bredr"
else
	echo "Error reading file, no 'ControllerMode' was recognised"
fi
sudo service bluetooth restart
