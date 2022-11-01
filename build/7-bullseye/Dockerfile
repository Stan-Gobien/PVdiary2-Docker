FROM php:7-bullseye

#Nameserver
ADD https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/resolv.conf /etc/resolv.conf

#Packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo sed cron vim procps zip unzip && apt-get clean

#PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
        install-php-extensions zip

#Files
ADD https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/entrypoint.sh /bin/entrypoint.sh
ADD https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/install.sh /bin/install.sh
ADD https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/PVdiary2/firstrun.sh /bin/firstrun.sh
RUN chmod +x /bin/entrypoint.sh
RUN chmod +x /bin/install.sh
RUN chmod +x /bin/firstrun.sh

## Set entrypoint
ENTRYPOINT [ "/bin/entrypoint.sh" ]
