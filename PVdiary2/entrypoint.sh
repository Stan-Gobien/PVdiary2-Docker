#!/bin/bash
echo Entrypoint.sh start
set -e

echo Update script files from Github
#You can disable this for security reasons or use your own repo with script files

curl -o  /bin/entrypoint.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/dev/entrypoint.sh --no-progress-meter
curl -o  /bin/dependencies.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/dev/dependencies.sh --no-progress-meter
curl -o  /bin/install.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/dev/install.sh --no-progress-meter
curl -o  /bin/firstrun.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/dev/firstrun.sh --no-progress-meter
curl -o  /bin/rclone.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/dev/rclone.sh --no-progress-meter
chmod +x /bin/entrypoint.sh && chmod +x /bin/dependencies.sh && chmod +x /bin/install.sh && chmod +x /bin/firstrun.sh && chmod +x /bin/rclone.sh

## Running passed command via exec
if [[ "$1" ]]; 
then
        eval "$@"
else
        echo Making sure executables are in the right locations
        if ! [ -L /usr/bin/php ] ; then ln -s /usr/local/bin/php /usr/bin/php ; fi        
        if ! [ -e /usr/local/bin/pvdiary ] ; then cp /home/pvdiary2/bin/pvdiary /usr/local/bin/pvdiary ; fi
        if ! [ -e /usr/local/bin/toolbin ] ; then cp /home/pvdiary2/bin/toolbin /usr/local/bin/toolbin ; fi
        
        sleep 10
        FILE=/var/.dependenciesfinished
        if [ -f "$FILE" ]
        then
            echo "Dependencies already installed. $FILE exists."
        else
            echo "Running dependencies installation via dependencies.sh"
            /bin/dependencies.sh
        fi
        sleep 5
        
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
