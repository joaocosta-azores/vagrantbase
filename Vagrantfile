# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_API_VERSION = "2"

PROJECT = 'project'
MYSQL_DB_NAME='project'
MYSQL_USER='root'
MYSQL_PASSWORD=''
EMAIL='joaocosta.azores@gmail.com'
VAGRANT_HOME='/home/vagrant'
INSTALL_NGINX_INSTEAD=0
INSTALL_POSTGRESQL=0
INSTALL_SQLITE=0
INSTALL_MONGODB=0
INSTALL_BEANSTALKD=0
INSTALL_WPCLI=0
INSTALL_DRUSH=0
INSTALL_NGROK=0
INSTALL_YARN=0
INSTALL_RUBY=0
INSTALL_REDIS=0
INSTALL_MEMCACHED=0
INSTALL_GOLANG=0
INSTALL_MAILHOG=0
XDEBUG_KEY=PROJECT + 'IDEKEY'

GUEST_HOSTNAME = PROJECT + ".local"
GUEST_NETWORK_IP = "192.168.59.80"
GUEST_MEMORY_LIMIT = "1024"
GUEST_CPU_LIMIT = "1"
GUEST_DIRECTORY = "/var/www/" + PROJECT

ARGS = {
        "PROJECT" => PROJECT,
        "MYSQL_PASSWORD" => MYSQL_PASSWORD,
        "MYSQL_DB_NAME" => MYSQL_DB_NAME,
        "MYSQL_USER" => MYSQL_USER,
        "EMAIL" => EMAIL,
        "GUEST_HOSTNAME" => GUEST_HOSTNAME,
        "GUEST_NETWORK_IP" => GUEST_NETWORK_IP,
        "GUEST_DIRECTORY" => GUEST_DIRECTORY,
        "VAGRANT_HOME" => VAGRANT_HOME,
        "INSTALL_NGINX_INSTEAD" => INSTALL_NGINX_INSTEAD,
        "INSTALL_POSTGRESQL" => INSTALL_POSTGRESQL,
        "INSTALL_SQLITE" => INSTALL_SQLITE,
        "INSTALL_MONGODB" => INSTALL_MONGODB,
        "INSTALL_BEANSTALKD" => INSTALL_BEANSTALKD,
        "INSTALL_WPCLI" => INSTALL_WPCLI,
        "INSTALL_NGROK" => INSTALL_NGROK,
        "INSTALL_YARN" => INSTALL_YARN,
        "INSTALL_RUBY" => INSTALL_RUBY,
        "INSTALL_REDIS" => INSTALL_REDIS,
        "INSTALL_MEMCACHED" => INSTALL_MEMCACHED,
        "INSTALL_GOLANG" => INSTALL_GOLANG,
        "INSTALL_MAILHOG" => INSTALL_MAILHOG,
        "XDEBUG_KEY" => XDEBUG_KEY
        }

Vagrant.configure("2") do |config|

    config.vm.box = "bento/ubuntu-16.04"

    config.vm.hostname = GUEST_HOSTNAME

    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "private_network", ip: GUEST_NETWORK_IP

    # Allow more memory usage for the VM
    config.vm.provider :virtualbox do |v|
        v.memory = GUEST_MEMORY_LIMIT
        v.cpus = GUEST_CPU_LIMIT
        v.name = GUEST_HOSTNAME
    end


    config.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=666"]

    # forward agent for ansible access
    config.ssh.forward_agent = true
    config.ssh.insert_key = false

    config.vm.provision "shell", path: "install/core.sh", privileged: false, env: ARGS
    config.vm.provision "shell", path: "install/apache.sh", privileged: false, env: ARGS
    config.vm.provision "shell", path: "install/nginx.sh", privileged: false, env: ARGS
    config.vm.provision "shell", path: "install/php.sh", privileged: false, env: ARGS
    config.vm.provision "shell", path: "install/database.sh", privileged: false, env: ARGS
    config.vm.provision "shell", path: "install/extras.sh", privileged: false, env: ARGS
    config.vm.provision "shell", path: "install/end.sh", privileged: false, env: ARGS

    #config.vm.provision "shell", path: "install.sh", privileged: false

end