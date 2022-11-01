#!/bin/bash
echo Entrypoint.sh start
set -e

echo Update script files from Github
#You can disable this for security reasons
curl -o  /bin/entrypoint.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/entrypoint.sh --no-progress-meter
curl -o  /bin/install.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/install.sh --no-progress-meter
curl -o  /bin/firstrun.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/firstrun.sh --no-progress-meter
curl -o  /bin/rclone.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/rclone.sh --no-progress-meter
chmod +x /bin/entrypoint.sh && chmod +x /bin/install.sh && chmod +x /bin/firstrun.sh && chmod +x /bin/rclone.sh

## Running passed command
if [[ "$1" ]]; 
then
        eval "$@"
else
        echo Making sure executables are in the right locations
        if ! [ -L /usr/bin/php ] ; then ln -s /usr/local/bin/php /usr/bin/php ; fi        
        if ! [ -e /usr/local/bin/pvdiary ] ; then cp /home/pvdiary2/bin/pvdiary /usr/local/bin/pvdiary ; fi
        if ! [ -e /usr/local/bin/toolbin ] ; then cp /home/pvdiary2/bin/toolbin /usr/local/bin/toolbin ; fi
        
        sleep 10
        FILE=/var/.installfinished
        if [ -f "$FILE" ]
        then
            echo "PVDiary has already been installed. $FILE exists."
        else
            echo "Running PVdiary installation via install.sh"
            /bin/install.sh
        fi
        sleep 5

        FILE=/home/pvdiary2/.firstrunfinished
        if [ -f "$FILE" ]
        then
            echo "PVdiary has already been configured. $FILE exists."
        else 
            echo "Running PVdiary configuration via firstrun.sh"
            /bin/firstrun.sh
        fi
        sleep 5
        
        FILE=/home/pvdiary2/.config/rclone/rclone.conf
        if [ -f "$FILE" ]
        then
            echo "rclone has already been configured. $FILE exists."
        else 
            echo "Creating rclone.config via rclone.sh"
            /bin/rclone.sh
        fi
        sleep 5        

        echo "Now starting CLI/dashboard & cron."
        sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --httpd --dashboard --start &
        sleep 5
        sudo -u pvdiary2 /home/pvdiary2/bin/toolbin --cliserver --start &
        sleep 5
        
        /usr/sbin/cron >> /home/pvdiary2/logs/cron.log &
        sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --autorun --run >> /home/pvdiary2/logs/cron.log 2>&1 &

        tail -f /home/pvdiary2/logs/cron.log
fi
