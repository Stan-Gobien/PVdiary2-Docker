#DNS Nameserver
curl -o  /etc/resolv.conf https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/resolv.conf --no-progress-meter

#Packages
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo sed cron vim procps zip unzip && apt-get clean

#PHP extensions
curl -o /usr/local/bin/install-php-extensions https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions --no-progress-meter
chmod +x /usr/local/bin/install-php-extensions && install-php-extensions zip
