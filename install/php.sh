#!/bin/bash

reboot_webserver_helper() {

    if [ $INSTALL_NGINX_INSTEAD != 1 ]; then
        sudo service apache2 restart
    fi

    if [ $INSTALL_NGINX_INSTEAD == 1 ]; then
        sudo systemctl restart php7.2-fpm
        sudo systemctl restart nginx
    fi

    echo 'Rebooting your webserver'
}



# /*===================================
# =            INSTALL PHP            =
# ===================================*/

# Install PHP
sudo add-apt-repository -y ppa:ondrej/php # Super Latest Version (currently 7.2)
sudo apt-get update
sudo apt-get install -y php7.2

# Make PHP and Apache friends
if [ $INSTALL_NGINX_INSTEAD != 1 ]; then

    sudo apt-get -y install libapache2-mod-php

    # Add index.php to readable file types
    MAKE_PHP_PRIORITY='<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
    </IfModule>'
    echo "$MAKE_PHP_PRIORITY" | sudo tee /etc/apache2/mods-enabled/dir.conf

    sudo service apache2 restart

fi

# Make PHP and NGINX friends
if [ $INSTALL_NGINX_INSTEAD == 1 ]; then

    # FPM STUFF
    sudo apt-get -y install php7.2-fpm
    sudo systemctl enable php7.2-fpm
    sudo systemctl start php7.2-fpm

    # Fix path FPM setting
    echo 'cgi.fix_pathinfo = 0' | sudo tee -a /etc/php/7.2/fpm/conf.d/user.ini
    sudo systemctl restart php7.2-fpm

    # Add index.php to readable file types and enable PHP FPM since PHP alone won't work
    MY_WEB_CONFIG='server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/public;
        index index.php index.html index.htm index.nginx-debian.html;

        server_name _;

        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/run/php/php7.2-fpm.sock;
        }

        location ~ /\.ht {
            deny all;
        }
    }'
    echo "$MY_WEB_CONFIG" | sudo tee /etc/nginx/sites-available/default

    sudo systemctl restart nginx

fi



# /*===================================
# =            PHP MODULES            =
# ===================================*/

# Base Stuff
sudo apt-get -y install php7.2-common
sudo apt-get -y install php7.2-dev

# Common Useful Stuff (some of these are probably already installed)
sudo apt-get -y install php7.2-bcmath
sudo apt-get -y install php7.2-bz2
sudo apt-get -y install php7.2-cgi
sudo apt-get -y install php7.2-cli
sudo apt-get -y install php7.2-fpm
sudo apt-get -y install php7.2-gd
sudo apt-get -y install php7.2-imap
sudo apt-get -y install php7.2-intl
sudo apt-get -y install php7.2-json
sudo apt-get -y install php7.2-mbstring
sudo apt-get -y install php7.2-odbc
sudo apt-get -y install php-pear
sudo apt-get -y install php7.2-pspell
sudo apt-get -y install php7.2-tidy
sudo apt-get -y install php7.2-xmlrpc
sudo apt-get -y install php7.2-zip

# Enchant
sudo apt-get -y install libenchant-dev
sudo apt-get -y install php7.2-enchant

# LDAP
sudo apt-get -y install ldap-utils
sudo apt-get -y install php7.2-ldap

# CURL
sudo apt-get -y install curl
sudo apt-get -y install php7.2-curl

# IMAGE MAGIC
sudo apt-get -y install imagemagick
sudo apt-get -y install php7.2-imagick

# XDEBUG
sudo apt-get -y install php7.2-xdebug
echo "xdebug.remote_enable=true" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.remote_connect_back=true" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.idekey=$XDEBUG_KEY" >> /etc/php/7.2/mods-available/xdebug.ini

# /*===========================================
# =            CUSTOM PHP SETTINGS            =
# ===========================================*/
if [ $INSTALL_NGINX_INSTEAD == 1 ]; then
    PHP_USER_INI_PATH=/etc/php/7.2/fpm/conf.d/user.ini
else
    PHP_USER_INI_PATH=/etc/php/7.2/apache2/conf.d/user.ini
fi

echo 'display_startup_errors = On' | sudo tee -a $PHP_USER_INI_PATH
echo 'display_errors = On' | sudo tee -a $PHP_USER_INI_PATH
echo 'error_reporting = E_ALL' | sudo tee -a $PHP_USER_INI_PATH
echo 'short_open_tag = On' | sudo tee -a $PHP_USER_INI_PATH
reboot_webserver_helper

# Disable PHP Zend OPcache
echo 'opache.enable = 0' | sudo tee -a $PHP_USER_INI_PATH

# Absolutely Force Zend OPcache off...
if [ $INSTALL_NGINX_INSTEAD == 1 ]; then
    sudo sed -i s,\;opcache.enable=0,opcache.enable=0,g /etc/php/7.2/fpm/php.ini
else
    sudo sed -i s,\;opcache.enable=0,opcache.enable=0,g /etc/php/7.2/apache2/php.ini
fi
reboot_webserver_helper


# /*===========================================
# =            MODE PAGE SPEED                =
# ===========================================*/

if [ $INSTALL_NGINX_INSTEAD == 1 ]; then
    sudo wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
    sudo dpkg -i mod-pagespeed-stable_current_amd64.deb
    sudo apt-get -f install
    sudo rm mod-pagespeed-stable_current_amd64.deb
fi


# /*================================
# =            PHP UNIT            =
# ================================*/
sudo wget https://phar.phpunit.de/phpunit-6.phar
sudo chmod +x phpunit-6.phar
sudo mv phpunit-6.phar /usr/local/bin/phpunit
reboot_webserver_helper
