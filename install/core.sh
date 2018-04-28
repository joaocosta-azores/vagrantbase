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



# /*=========================================
# =            CORE / BASE STUFF            =
# =========================================*/
sudo apt-get update

# The following is "sudo apt-get -y upgrade" without any prompts
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

sudo apt-get install -y build-essential
sudo apt-get install -y tcl
sudo apt-get install -y software-properties-common
sudo apt-get install -y python-software-properties
sudo apt-get -y install vim
sudo apt-get -y install git

# Weird Vagrant issue fix
sudo apt-get install -y ifupdown
