# Vagrant custom instalation

Choose what do you want to install beside LAMP

Base installaion comes with:

APACHE 2
PHP 7.2
MYSQL 5.7

In your hosts files point GUEST_NETWORK_IP to GUEST_HOSTNAME set in Vangratfile.


Example:

If you have in your Vagrantfile:

PROJECT = 'vagrant'
TLD='local'
GUEST_NETWORK_IP = "192.168.59.80"

Then point in your hosts file:

192.168.59.80     vagrant.local


## Octobercms Installation

To install October Cms turn octobercms parameter to 1 in Vagrantfile.

After vagrant up run vagrant ssh and then run the following commands:

php /var/www/public/artisan key:generate
php /var/www/public/artisan october:install