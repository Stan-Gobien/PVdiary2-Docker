# Home dir
mkdir /home/pvdiary2

# Create Group
groupadd -g 5000 pvdiary2

# Create User
useradd -d /home/pvdiary2 -u 5000 -g 5000 -M -N -s /bin/bash pvdiary2

# Install PVdiary2
mkdir /home/pvdiary2/incl && mkdir /home/pvdiary2/httpd
chown -R pvdiary2:pvdiary2 /home/pvdiary2 && chmod -R 755 /home/pvdiary2
ls -al /home && ls -al /home/pvdiary2  
cd /home/pvdiary2 \
  && pwd \
  && sudo -u pvdiary2 curl -o /home/pvdiary2/install_pvdiary.php https://www.aps11tl.be/download.php?id=pvdiary_installer \
  && sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --download \
  && sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --list \ 
  && sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --unzip
  
ls -al /home/pvdiary2/ && ls -al /home/pvdiary2/incl/ \
  && sed -i 's/if (!self::g_ask_yn(" Continue with these/\/\/if (!self::g_ask_yn(" Continue with these/g' /home/pvdiary2/incl/tlbn__setup.php
cd /home/pvdiary2 \
  && sudo -u pvdiary2 mkdir /home/pvdiary2/temp \
  && chmod 777 /home/pvdiary2/temp \
  && sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --setup --CLI=/home/pvdiary2/temp \
  && ls -al /home/pvdiary2/temp \
  && cp /home/pvdiary2/temp/* /usr/local/bin/ -v \
  && sudo -u pvdiary2 pvdiary --check-env

# Change PVdiary2 settings for dashboard accessible from anywhere and remove login/password need
# Only use this in a trusted network, not the public internet
sed -i 's/localhost:8082/0.0.0.0:8082/g' /home/pvdiary2/g_toolbin_cfg.php
sed -i "s/define('TOOLBIN_SOS',false)/define('TOOLBIN_SOS',true)/g" /home/pvdiary2/g_toolbin_cfg.php

# Autorun config
sed -i "s/\; exec_at_start\[] = \"pvdiary / exec_at_start\[] = \"pvdiary /g" /home/pvdiary2/etc/pvdiary.cfg
sed -i "s/\; exec_at_start\[] = \"toolbin / exec_at_start\[] = \"toolbin /g" /home/pvdiary2/etc/pvdiary.cfg

# Cronjobs
printf '@reboot pvdiary2 /usr/local/bin/pvdiary --autorun --run --sleep=20 >> /var/log/cron.log 2>&1 \n' > /etc/cron.d/pvdiary2
printf '0 4 * * * pvdiary2 /usr/local/bin/pvdiary --autorun --run >> /var/log/cron.log 2>&1 \n' >> /etc/cron.d/pvdiary2
printf '0 12 * * 6 pvdiary2 /usr/local/bin/pvdiary --plugin=update-sw --code-php --code-www >> /var/log/cron.log 2>&1 \n' >> /etc/cron.d/pvdiary2
chmod 0644 /etc/cron.d/pvdiary2
crontab /etc/cron.d/pvdiary2
touch /var/log/cron.log

# Demo config PVdiary2
#sudo -u pvdiary2 pvdiary --plugin=config --create-demo
#sudo -u pvdiary2 pvdiary --db --make-tables --init
#sudo -u pvdiary2 pvdiary --import --start-date=day1
#sudo -u pvdiary2 pvdiary --plugin=config --show-cfg
#sudo -u pvdiary2 pvdiary --plugin=config --show-cfg
#sudo -u pvdiary2 pvdiary --export --info --expected --top


# Rclone, to difficult to include at build time, will have to create at RUN time
#ENV TYPE=ftp
#ENV HOST=
#ENV USER=
#ENV PASS=
#RUN sudo -u pvdiary2 rclone config create pvdiary ftp host www.gobien.be user xxxx pass yyyyy

# Create file to let startup know firstrun is done
sudo -u pvdiary2 touch /home/pvdiary2/.firstrunfinished
