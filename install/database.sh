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



# /*=============================
# =            MYSQL            =
# =============================*/
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server
sudo mysqladmin -uroot -p'root' password ''
sudo mysqladmin -uroot create $MYSQL_DB_NAME
sudo apt-get -y install php7.2-mysql
reboot_webserver_helper








# /*=================================
# =            PostreSQL            =
# =================================*/


if [ $INSTALL_POSTGRESQL == 1 ]; then
sudo apt-get -y install postgresql postgresql-contrib
echo "CREATE ROLE root WITH LOGIN ENCRYPTED PASSWORD 'root';" | sudo -i -u postgres psql
sudo -i -u postgres createdb --owner=root scotchbox
sudo apt-get -y install php7.2-pgsql
reboot_webserver_helper
fi






# /*==============================
# =            SQLITE            =
# ===============================*/


if [ $INSTALL_SQLITE == 1 ]; then
sudo apt-get -y install sqlite
sudo apt-get -y install php7.2-sqlite3
reboot_webserver_helper
fi






# /*===============================
# =            MONGODB            =
# ===============================*/


if [ $INSTALL_MONGODB == 1 ]; then
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org

sudo tee /lib/systemd/system/mongod.service  <<EOL
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target
Documentation=https://docs.mongodb.org/manual

[Service]
User=mongodb
Group=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target
EOL
sudo systemctl enable mongod
sudo service mongod start

# Enable it for PHP
sudo pecl install mongodb
sudo apt-get install -y php7.2-mongodb

reboot_webserver_helper
fi
