echo Time settings
TZ=${TIMEZONE}
dpkg-reconfigure -f noninteractive tzdata

echo PHP symlink
if ! [/usr/bin/php]
then
        ln -s /usr/local/bin/php /usr/bin/php
fi

echo PHP time settings
PHPCONFPATH=$(php -i | grep 'additional .ini files' |  grep -o '/[^ ]*')
printf "[PHP]\ndate.timezone = \"${TIMEZONE}\"\n" > $PHPCONFPATH/90-timezone.ini && cat $PHPCONFPATH/90-timezone.ini


echo Create Group
groupadd -g 5000 pvdiary2

echo Create User
mkdir /home/pvdiary2
useradd -d /home/pvdiary2 -u 5000 -g 5000 -M -N -s /bin/bash pvdiary2

echo Install PVdiary2
mkdir /home/pvdiary2/incl
mkdir /home/pvdiary2/httpd
mkdir /home/pvdiary2/logs
mkdir /home/pvdiary2/tmp
mkdir /home/pvdiary2/bin
touch /home/pvdiary2/logs/cron.log

chown -R pvdiary2:pvdiary2 /home/pvdiary2 && chmod -R 755 /home/pvdiary2
cd /home/pvdiary2
echo Download pvdiary_installer
sudo -u pvdiary2 curl -o /home/pvdiary2/install_pvdiary.php https://www.aps11tl.be/download.php?id=pvdiary_installer
sleep 1
sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --download
sleep 1
sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --list
sleep 1
sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --unzip
sleep 1

echo Use sed to remove confirm question
sed -i 's/if (!self::g_ask_yn(" Continue with these/\/\/if (!self::g_ask_yn(" Continue with these/g' /home/pvdiary2/incl/tlbn__setup.php
cd /home/pvdiary2
chmod 777 /home/pvdiary2/bin
sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --setup --CLI=/home/pvdiary2/bin
chmod +x /home/pvdiary2/bin/*
ls -alth /home/pvdiary2/bin

echo Copy executbales to /usr/local/bin
if ! [/usr/local/bin/pvdiary]
then
        cp /home/pvdiary2/bin/pvdiary /usr/local/bin/pvdiary
fi
if ! [/usr/local/bin/toolbin]
then
       cp /home/pvdiary2/bin/toolbin /usr/local/bin/toolbin
fi   
ls -alth /usr/local/bin/

echo Check PVdiary2 env
sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --check-env

echo Change PVdiary2 settings to dashboard accessible from anywhere and remove login/password need
echo Only use this in a trusted network, not the public internet
sed -i 's/localhost:8082/0.0.0.0:8082/g' /home/pvdiary2/g_toolbin_cfg.php
sed -i "s/define('TOOLBIN_SOS',false)/define('TOOLBIN_SOS',true)/g" /home/pvdiary2/g_toolbin_cfg.php

echo Cronjobs
printf '@reboot pvdiary2 /home/pvdiary2/bin/pvdiary --autorun --run --sleep=20 >> /home/pvdiary2/logs/cron.log 2>&1 \n' > /etc/cron.d/pvdiary2
printf '0 4 * * * pvdiary2 /home/pvdiary2/bin/pvdiary --autorun --run >> /home/pvdiary2/logs/cron.log 2>&1 \n' >> /etc/cron.d/pvdiary2
printf '0 12 * * 6 pvdiary2 /home/pvdiary2/bin/pvdiary --plugin=update-sw --code-php --code-www >> /home/pvdiary2/logs/cron.log 2>&1 \n' >> /etc/cron.d/pvdiary2
chmod 0644 /etc/cron.d/pvdiary2
crontab /etc/cron.d/pvdiary2

echo Install rclone
curl https://rclone.org/install.sh | sudo bash

echo "Create file to indicate install.sh is finished"
touch /var/.installfinished
