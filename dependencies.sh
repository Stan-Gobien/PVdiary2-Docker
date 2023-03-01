#DNS Nameserver
echo "Create a resolv.conf file"
curl -o  /etc/resolv.conf https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/resolv.conf --no-progress-meter

#Packages
echo "Install packages"
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo sed cron vim procps zip unzip php7.4-zip && apt-get clean

#PHP extensions
echo "Install php extension"
curl -o /usr/local/bin/install-php-extensions https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions --no-progress-meter
chmod +x /usr/local/bin/install-php-extensions && install-php-extensions zip

echo "Create file to let startup know entrypoint is finished"
touch /var/.dependenciesfinished

sleep 60
