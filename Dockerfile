FROM debian:latest as debian-php

LABEL com.centurylinklabs.watchtower.enable="true"

# Install deps
RUN ["/bin/bash", "-c", "set -o pipefail \
  && DEBIAN_FRONTEND=noninteractive \
    apt update && apt install --assume-yes --no-install-recommends \
      vim \
      curl \
      wget \
      php-cli \
      php-readline \
      php-json \
      php-zip \
      php-sqlite3 \
      php-curl \
      tzdata \
      cron \
      sed \
      rclone \
      sudo \
      procps \
      ca-certificates \
  && rm -rf /var/lib/apt/lists/*"]

# Time settings
ENV TZ=Europe/Brussels
RUN rm /etc/localtime && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# PHP time settings
RUN ["/bin/bash", "-c", "set -o pipefail \
  && PHPCONFPATH=$(php -i | grep 'additional .ini files' |  grep -o '/[^ ]*') \
  && printf '[PHP]\ndate.timezone = \"Europe/Brussels\"\n' > $PHPCONFPATH/90-timezone.ini && cat $PHPCONFPATH/90-timezone.ini"]
  
FROM debian-php as debian-php-pvdiary-install

LABEL maintainer="stan@gobien.be"
LABEL com.centurylinklabs.watchtower.enable="false"

# Create User
RUN useradd --create-home --home /home/pvdiary2 --shell /bin/bash --user-group pvdiary2

# Volume
VOLUME /home/pvdiary2

# Home dir
RUN mkdir /home/pvdiary2/incl && mkdir /home/pvdiary2/httpd
RUN chown -R pvdiary2:pvdiary2 /home/pvdiary2 && chmod -R 755 /home/pvdiary2
RUN ls -al /home && ls -al /home/pvdiary2  

# Install PVdiary2
RUN cd /home/pvdiary2 \
  && pwd \
  && sudo -u pvdiary2 curl -o /home/pvdiary2/install_pvdiary.php https://www.aps11tl.be/download.php?id=pvdiary_installer \
  && sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --download \
  && sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --list \ 
  && sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --unzip
RUN ls -al /home/pvdiary2/ && ls -al /home/pvdiary2/incl/ \
  && sed -i 's/if (!self::g_ask_yn(" Continue with these/\/\/if (!self::g_ask_yn(" Continue with these/g' /home/pvdiary2/incl/tlbn__setup.php
RUN cd /home/pvdiary2 \
  && sudo -u pvdiary2 mkdir /home/pvdiary2/temp \
  && chmod 777 /home/pvdiary2/temp \
  && sudo -u pvdiary2 php /home/pvdiary2/install_pvdiary.php --setup --CLI=/home/pvdiary2/temp \
  && ls -al /home/pvdiary2/temp \
  && cp /home/pvdiary2/temp/* /usr/local/bin/ -v \
  && sudo -u pvdiary2 pvdiary --check-env

# Change PVDiary settings for dashboard accessible from anywhere and remove login/password need
RUN sed -i 's/localhost:8082/0.0.0.0:8082/g' /home/pvdiary2/g_toolbin_cfg.php
RUN sed -i "s/define('TOOLBIN_SOS',false)/define('TOOLBIN_SOS',true)/g" /home/pvdiary2/g_toolbin_cfg.php

FROM debian-php-pvdiary-install as debian-php-pvdiary-install-demo

# Start PVdiary dashboard & CLI
RUN sudo -u pvdiary2 toolbin --cliserver --start
RUN sudo -u pvdiary2 pvdiary --httpd --dashboard --start

# Demo config PVdiary2
RUN sudo -u pvdiary2 pvdiary --plugin=config --create-demo
RUN sudo -u pvdiary2 pvdiary --db --make-tables --init
RUN sudo -u pvdiary2 pvdiary --import --start-date=day1
RUN sudo -u pvdiary2 pvdiary --plugin=config --show-cfg
RUN sudo -u pvdiary2 pvdiary --plugin=config --show-cfg
RUN sudo -u pvdiary2 pvdiary --export --info --expected --top

# Autorun config
RUN sed -i "s/\; exec_at_start\[] = \"pvdiary / exec_at_start\[] = \"pvdiary /g" /home/pvdiary2/etc/pvdiary.cfg
RUN sed -i "s/\; exec_at_start\[] = \"toolbin / exec_at_start\[] = \"toolbin /g" /home/pvdiary2/etc/pvdiary.cfg

# Cronjobs
RUN printf '@reboot pvdiary2 /usr/local/bin/pvdiary --autorun --run --sleep=20 >> /var/log/cron.log 2>&1 \n' > /etc/cron.d/pvdiary2
RUN printf '0 4 * * * pvdiary2 /usr/local/bin/pvdiary --autorun --run >> /var/log/cron.log 2>&1 \n' >> /etc/cron.d/pvdiary2
RUN printf '0 12 * * 6 pvdiary2 /usr/local/bin/pvdiary --plugin=update-sw --code-php --code-www >> /var/log/cron.log 2>&1 \n' >> /etc/cron.d/pvdiary2
RUN chmod 0644 /etc/cron.d/pvdiary2
RUN crontab /etc/cron.d/pvdiary2
RUN touch /var/log/cron.log

# Rclone, to difficult to include at build time, will have to create at RUN time
#ENV TYPE=ftp
#ENV HOST=
#ENV USER=
#ENV PASS=
#RUN sudo -u pvdiary2 rclone config create pvdiary ftp host www.gobien.be user www.gobien.be pass

# Ports
EXPOSE 8082/tcp

# Healthcheck
#HEALTHCHECK --interval=5m --timeout=10s \
#  CMD ps -aux | grep cron || exit 1

# Run the command on container startup
CMD cron >> /var/log/cron.log && tail -f /var/log/cron.log
