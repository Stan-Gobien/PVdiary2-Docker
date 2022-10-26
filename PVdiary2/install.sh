echo Time settings
TZ=Europe/Brussels
dpkg-reconfigure -f noninteractive tzdata

echo PHP time settings
PHPCONFPATH=$(php -i | grep 'additional .ini files' |  grep -o '/[^ ]*')
printf '[PHP]\ndate.timezone = \"Europe/Brussels\"\n' > $PHPCONFPATH/90-timezone.ini && cat $PHPCONFPATH/90-timezone.ini

echo Home dir
mkdir /home/pvdiary2

echo Create Group
groupadd -g 5000 pvdiary2

echo Create User
useradd -d /home/pvdiary2 -u 5000 -g 5000 -M -N -s /bin/bash pvdiary2

echo Install PVdiary2
mkdir /home/pvdiary2/incl && mkdir /home/pvdiary2/httpd
chown -R pvdiary2:pvdiary2 /home/pvdiary2 && chmod -R 755 /home/pvdiary2
echo List conent of /home en /home/pvdiary2 for debug reasons
ls -al /home && ls -al /home/pvdiary2  
cd /home/pvdiary2 && pwd
echo Download pvdiary_installer
sudo -u pvdiary2 curl -o /home/pvdiary2/install_pvdiary.php https://www.aps11tl.be/download.php?id=pvdiary_installer
sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --download
sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --list
sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --unzip

echo List conent of /home/pvdiary2 en /home/pvdiary2/incl for debug reasons
ls -al /home/pvdiary2/ && ls -al /home/pvdiary2/incl/

echo Use sed to make installer non-interactive proof
sed -i 's/if (!self::g_ask_yn(" Continue with these/\/\/if (!self::g_ask_yn(" Continue with these/g' /home/pvdiary2/incl/tlbn__setup.php
cd /home/pvdiary2
sudo -u pvdiary2 mkdir /home/pvdiary2/temp
chmod 777 /home/pvdiary2/temp
sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --setup --CLI=/home/pvdiary2/temp

echo List conent of /home/pvdiary2/temp for debug reasons
ls -al /home/pvdiary2/temp
cp -v /home/pvdiary2/temp/toolbin /usr/local/bin/toolbin
cp -v /home/pvdiary2/temp/pvdiary /usr/local/bin/pvdiary
chmod +x /usr/local/bin/pvdiary
chmod +x /usr/local/bin/toolbin

echo Check PVdiary2 env
sudo -u pvdiary2 /usr/local/bin/pvdiary --check-env

echo Change PVdiary2 settings to dashboard accessible from anywhere and remove login/password need
# Only use this in a trusted network, not the public internet
sed -i 's/localhost:8082/0.0.0.0:8082/g' /home/pvdiary2/g_toolbin_cfg.php
sed -i "s/define('TOOLBIN_SOS',false)/define('TOOLBIN_SOS',true)/g" /home/pvdiary2/g_toolbin_cfg.php

echo Cronjobs
printf '@reboot pvdiary2 /usr/local/bin/pvdiary --autorun --run --sleep=20 >> /var/log/cron.log 2>&1 \n' > /etc/cron.d/pvdiary2
printf '0 4 * * * pvdiary2 /usr/local/bin/pvdiary --autorun --run >> /var/log/cron.log 2>&1 \n' >> /etc/cron.d/pvdiary2
printf '0 12 * * 6 pvdiary2 /usr/local/bin/pvdiary --plugin=update-sw --code-php --code-www >> /var/log/cron.log 2>&1 \n' >> /etc/cron.d/pvdiary2
chmod 0644 /etc/cron.d/pvdiary2
crontab /etc/cron.d/pvdiary2
touch /var/log/cron.log

echo Create file to let startup know install is already done
touch /var/.installfinished
