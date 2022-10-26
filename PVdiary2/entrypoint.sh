#!/usr/bin/env bash
set -e

## Run startup command
#echo "Hello ENTRYPOINT" >> hello

FILE=/var/.installfinished
if [ -f "$FILE" ]; then
    echo "PVDiary has already been installed. $FILE exists."
else
    echo "Running PVdiary installation via installn.sh"
    /bin/install.sh
fi

FILE=/home/pvdiary2/.firstrunfinished
if [ -f "$FILE" ]; then
    echo "PVdiary has already been configured. $FILE exists."
else 
    echo "Running PVdiary configuration via FirstRun.sh"
    /bin/firstrun.sh
fi
    echo "Now starting CLI/dashboard & cron."
    sudo -u pvdiary2 toolbin --cliserver --start
    sudo -u pvdiary2 pvdiary --httpd --dashboard --start
    /usr/sbin/cron >> /var/log/cron.log &
    tail -f /var/log/cron.log
 

## Running passed command
if [[ "$1" ]]; then
        eval "$@"
fi
