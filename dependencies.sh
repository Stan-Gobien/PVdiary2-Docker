#DNS Nameserver
echo "Create a resolv.conf file"
curl -o  /etc/resolv.conf https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/resolv.conf --no-progress-meter

#Packages
echo "Install packages"
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo sed cron vim procps zip unzip && apt-get clean

#PHP extensions
echo "Install php extension"
curl -o /usr/local/bin/install-php-extensions https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions --no-progress-meter
chmod +x /usr/local/bin/install-php-extensions 
/usr/local/bin/install-php-extensions zip

echo "Create file to indicate dependencies.sh has run"
touch /var/.dependenciesfinished
sleep 5
