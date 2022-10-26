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
 
