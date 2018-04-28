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



# /*================================
# =            COMPOSER            =
# ================================*/
EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
php composer-setup.php --quiet
rm composer-setup.php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod 755 /usr/local/bin/composer



# /*==================================
# =            BEANSTALKD            =
# ==================================*/


if [ $INSTALL_BEANSTALKD == 1 ]; then
    sudo apt-get -y install beanstalkd
fi


# /*==============================
# =            WP-CLI            =
# ==============================*/


if [ $INSTALL_WPCLI == 1 ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    sudo chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
fi


# /*=============================
# =            DRUSH            =
# =============================*/


if [ $INSTALL_DRUSH == 1 ]; then
    wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.5.1/drush.phar
    sudo chmod +x drush.phar
    sudo mv drush.phar /usr/local/bin/drush
fi


# /*=============================
# =            NGROK            =
# =============================*/


if [ $INSTALL_NGROK == 1 ]; then
    sudo apt-get install ngrok-client
fi


# /*==============================
# =            NODEJS            =
# ==============================*/
sudo apt-get -y install nodejs
sudo apt-get -y install npm

sudo npm install -g npm

# Use NVM though to make life easy
wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | bash
source ~/.nvm/nvm.sh
nvm install 8.9.4

echo 'Node installed'

# Node Packages
sudo npm install -g gulp-cli
echo 'Node Glup-cli installed'
sudo npm install gulp -D
echo 'Node Glup installed'
#sudo npm install -g grunt-cli
#sudo npm install -g bower
#sudo npm install -g yo
sudo npm install -g browser-sync
echo 'Node Browser Sync installed'
#sudo npm install -g browserify
#sudo npm install -g pm2



# /*============================
# =            YARN            =
# ============================*/

if [ $INSTALL_YARN == 1 ]; then
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update
    sudo apt-get -y install yarn
fi



# /*============================
# =            RUBY            =
# ============================*/


if [ $INSTALL_RUBY == 1 ]; then
    sudo apt-get -y install ruby
    sudo apt-get -y install ruby-dev

    # Use RVM though to make life easy
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    \curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
    rvm install 2.5.0
    rvm use 2.5.0
fi


# /*=============================
# =            REDIS            =
# =============================*/


if [ $INSTALL_REDIS == 1 ]; then
    sudo apt-get -y install redis-server
    sudo apt-get -y install php7.2-redis
    reboot_webserver_helper
fi


# /*=================================
# =            MEMCACHED            =
# =================================*/


if [ $INSTALL_MEMCACHED == 1 ]; then
    sudo apt-get -y install memcached
    sudo apt-get -y install php7.2-memcached
    reboot_webserver_helper
fi


# /*==============================
# =            GOLANG            =
# ==============================*/


if [ $INSTALL_GOLANG == 1 ]; then
    sudo add-apt-repository -y ppa:longsleep/golang-backports
    sudo apt-get update
    sudo apt-get -y install golang-go
fi


# /*===============================
# =            MAILHOG            =
# ===============================*/


if [ $INSTALL_MAILHOG == 1 ]; then
sudo wget --quiet -O ~/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64
sudo chmod +x ~/mailhog

# Enable and Turn on
sudo tee /etc/systemd/system/mailhog.service <<EOL
[Unit]
Description=MailHog Service
After=network.service vagrant.mount
[Service]
Type=simple
ExecStart=/usr/bin/env /home/vagrant/mailhog > /dev/null 2>&1 &
[Install]
WantedBy=multi-user.target
EOL
sudo systemctl enable mailhog
sudo systemctl start mailhog

# Install Sendmail replacement for MailHog
sudo go get github.com/mailhog/mhsendmail
sudo ln ~/go/bin/mhsendmail /usr/bin/mhsendmail
sudo ln ~/go/bin/mhsendmail /usr/bin/sendmail
sudo ln ~/go/bin/mhsendmail /usr/bin/mail

    # Make it work with PHP
    if [ $INSTALL_NGINX_INSTEAD == 1 ]; then
        echo 'sendmail_path = /usr/bin/mhsendmail' | sudo tee -a /etc/php/7.2/fpm/conf.d/user.ini
    else
        echo 'sendmail_path = /usr/bin/mhsendmail' | sudo tee -a /etc/php/7.2/apache2/conf.d/user.ini
    fi
fi
reboot_webserver_helper

