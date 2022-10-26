#!/usr/bin/env bash
set -e

## Running passed command
if [[ "$1" ]]; then
        eval "$@"
fi

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
sudo -u pvdiary2 /usr/local/bin/pvdiary --autorun --run >> /var/log/cron.log 2>&1 &

tail -f /var/log/cron
