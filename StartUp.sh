FILE=/home/pvdiary2/.firstrunfinished
if [ -f "$FILE" ]; then
    echo "PVDiary has already been configured. $FILE exists."
else 
    echo "Running PVDiary configuration via FirstRun.sh"
    /usr/bin/PVdiary-firstrun.sh
fi
    echo "Now starting CLI/dashboard & cron."
    sudo -u pvdiary2 toolbin --cliserver --start
    sudo -u pvdiary2 pvdiary --httpd --dashboard --start
    cron >> /var/log/cron.log && tail -f /var/log/cron.log
