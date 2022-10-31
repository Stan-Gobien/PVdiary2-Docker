#!/usr/bin/env bash
echo Entrypoint.sh start
set -e

echo Update script files
curl -o  /bin/entrypoint.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/entrypoint.sh >/dev/null 2>&1
curl -o  /bin/install.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/install.sh >/dev/null 2>&1
curl -o  /bin/firstrun.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/firstrun.sh >/dev/null 2>&1

#if ! [ -L /usr/local/bin/php ]; then
#        ln -s /usr/local/bin/php /usr/bin/php
#fi

## Running passed command
if [[ "$1" ]]; 
then
        eval "$@"
else

        sleep 20
        FILE=/var/.installfinished
        if [ -f "$FILE" ]; then
            echo "PVDiary has already been installed. $FILE exists."
        else
            echo "Running PVdiary installation via install.sh"
            /bin/install.sh
        fi
        sleep 5

        FILE=/home/pvdiary2/.firstrunfinished
        if [ -f "$FILE" ]; then
            echo "PVdiary has already been configured. $FILE exists."
        else 
            echo "Running PVdiary configuration via FirstRun.sh"
            /bin/firstrun.sh
        fi
        sleep 5

        export PATH="/home/pvdiary2/bin:$PATH"
        ln -s /home/pvdiary2/bin/toolbin /usr/local/bin/toolbin
        ln -s /home/pvdiary2/bin/pvdiary /usr/local/bin/pvdiary    

        echo "Now starting CLI/dashboard & cron."
        sudo -u pvdiary2 /home/pvdiary2/bin/toolbin --cliserver --start &
        sleep 2
        sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --httpd --dashboard --start &
        sleep 300

        /usr/sbin/cron >> /home/pvdiary2/logs/cron.log &
        sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --autorun --run >> /home/pvdiary2/logs/cron.log 2>&1 &

        tail -f /home/pvdiary2/logs/cron.log
fi

