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



# /*======================================
# =            INSTALL APACHE            =
# ======================================*/
if [ $INSTALL_NGINX_INSTEAD != 1 ]; then

    # Install the package
    sudo add-apt-repository -y ppa:ondrej/apache2 # Super Latest Version
    sudo apt-get update
    sudo apt-get -y install apache2

    # Remove "html" and add public
    sudo mv /var/www/html /var/www/public

    # Clean VHOST with full permissions
    MY_WEB_CONFIG='<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/public
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        <Directory "/var/www/public">
            Options Indexes FollowSymLinks
            AllowOverride all
            Require all granted
        </Directory>
    </VirtualHost>'
    echo "$MY_WEB_CONFIG" | sudo tee /etc/apache2/sites-available/000-default.conf

    # Squash annoying FQDN warning
    echo "ServerName scotchbox" | sudo tee /etc/apache2/conf-available/servername.conf
    sudo a2enconf servername

    # Enabled missing h5bp modules (https://github.com/h5bp/server-configs-apache)
    sudo a2enmod expires
    sudo a2enmod headers
    sudo a2enmod include
    sudo a2enmod rewrite

    sudo service apache2 restart

fi
