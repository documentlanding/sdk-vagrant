#!/usr/bin/env bash

apt-get -y install --only-upgrade bash


########### Install Server Requirements ############

apt-get -y install php5 php5-fpm php5-curl php5-dev php5-cli php5-dev php5-intl php5-mysql curl nginx
curl -s http://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer.phar


########### Configure MySQL Server ############

echo "mysql-server mysql-server/root_password select dbroot123" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again select dbroot123" | debconf-set-selections
apt-get -y install mysql-server-5.6

mysql -u root -pdbroot123 -e "CREATE DATABASE IF NOT EXISTS sdk_documentlanding CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -u root -pdbroot123 -e "grant all privileges on sdk_documentlanding.* to sdk_user@localhost identified by 'sdk_pass';"


########### Create Document Root ############

mkdir /var/www/html/sdk.documentlanding.com


########### Configure NGINX ############

cp /vagrant/templates/nginx-server.default /etc/nginx/sites-available/default
service nginx restart


########### Install and Configure Symfony2 Project ############

## Download and Extract Project
curl -O https://github.com/documentlanding/sdk-demo-project/archive/master.tar.gz
tar -zxvf master.tar.gz -C /var/www/html/sdk.documentlanding.com
cd /var/www/html/sdk.documentlanding.com

## Install Everything with Composer
php /usr/local/bin/composer.phar install --prefer-dist --no-interaction --optimize-autoloader

## Add Bundle Configuration to Config.yml
echo "
sdk:
    api_key: ThisTokenIsNotSoSecretChangeIt
    lead_class: DocumentLanding\SdkDemoBundle\Entity\Lead
    receipt_email: ~
    audit: ~" >> /var/www/html/sdk.documentlanding.com/app/config/config.yml

## Replace AppKernel.php to include the Bundles
cp /vagrant/templates/AppKernel.php /var/www/html/sdk.documentlanding.com/app/AppKernel.php

## Configure ACL on app/cache and app/logs
apt-get install acl
mkdir -p app/cache app/logs
chown -R www-data:www-data app/cache app/logs
chmod g+s app/cache app/logs
setfacl -R -m u:www-data:rwx app/cache app/logs
setfacl -dR -m u:www-data:rwx app/cache app/logs

## Clear Cache
php app/console cache:clear