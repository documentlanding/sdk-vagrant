#!/usr/bin/env bash

apt-get -y install --only-upgrade bash


########### Install Server Requirements ############

apt-get -y install php5 php5-fpm php5-curl php5-dev php5-cli php5-dev php5-intl php5-mysql curl git nginx
curl -s http://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer.phar


########### Configure MySQL Server ############

echo "mysql-server mysql-server/root_password select dbroot123" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again select dbroot123" | debconf-set-selections
apt-get -y install mysql-server-5.6

mysql -u root -pdbroot123 -e "CREATE DATABASE IF NOT EXISTS sdk_documentlanding CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -u root -pdbroot123 -e "grant all privileges on sdk_documentlanding.* to sdk_user@localhost identified by 'sdk_pass';"


########### Install & Configure HHVM ############

#locale-gen en_US.UTF-8
#dpkg-reconfigure locales
#
#apt-get -y install software-properties-common
#apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
#add-apt-repository 'deb http://dl.hhvm.com/ubuntu trusty main'
#apt-get update
#apt-get -y install hhvm
#
#echo "hhvm.libxml.ext_entity_whitelist = file,http" >> /etc/hhvm/php.ini
#echo 'date.timezone="America/Chicago"' >> /etc/hhvm/php.ini


########### Install and Configure Symfony2 Project ############

## Create Symfony2 Project
mkdir -p /var/www/html
curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
chmod a+x /usr/local/bin/symfony
cd /var/www/html
sudo symfony new sdk.documentlanding.com 2.7

## Replace composer.json
cp /vagrant/templates/composer.json /var/www/html/sdk.documentlanding.com/composer.json

## Install Everything with Composer
## Use HHVM for performance
cd /var/www/html/sdk.documentlanding.com
# hhvm /usr/local/bin/composer.phar update
php /usr/local/bin/composer.phar update

## Add Bundle Configuration to Config.yml
echo "
sdk:
    api_key: ThisTokenIsNotSoSecretChangeIt
    lead_class: DocumentLanding\SdkDemoBundle\Entity\Lead
    receipt_email: ~
    audit: ~" >> /var/www/html/sdk.documentlanding.com/app/config/config.yml

## Replace AppKernel.php
cp /vagrant/templates/AppKernel.php /var/www/html/sdk.documentlanding.com/app/AppKernel.php

## Replace AppKernel.php to include the Bundles
cp /vagrant/templates/parameters.yml /var/www/html/sdk.documentlanding.com/app/config/parameters.yml

## Replace app_dev.php
cp /vagrant/templates/app_dev.php /var/www/html/sdk.documentlanding.com/web/app_dev.php

## Replace routing.yml
cp /vagrant/templates/routing.yml /var/www/html/sdk.documentlanding.com/app/config/routing.yml

## Configure ACL on app/cache and app/logs
apt-get install acl
mkdir -p app/cache app/logs
chown -R www-data:www-data app/cache app/logs
chmod g+s app/cache app/logs
setfacl -R -m u:www-data:rwx app/cache app/logs
setfacl -dR -m u:www-data:rwx app/cache app/logs

## Clear Cache
## Use PHP5-FPM to avoid cache incompatibility with HHVM
php app/console cache:clear


########### Configure NGINX ############

cp /vagrant/templates/nginx-server.default /etc/nginx/sites-available/default
service nginx restart
