# PHP 7.0 Install Instructions

## Ajout du dépot Dotdeb

```bash
# ALL COMMANDS MUST BE EXECUTED WITH ROOT USER !
sudo su
echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list
wget -O- https://www.dotdeb.org/dotdeb.gpg | apt-key add -
apt-get update
```

## Suppression de PHP 5

```bash
systemctl stop php5-fpm
/etc/init.d/apache2 stop
apt-get autoremove --purge php5*
```

## Installation de PHP 7 ainsi que quelques dépendances

```bash
apt-get install php7.0 libapache2-mod-php7.0
apt-get install php7.0-fpm php7.0-mysql php7.0-curl php7.0-json php7.0-mcrypt php7.0-imap php7.0-xsl
apt-get install php7.0-mongodb php-pear php7.0-imagick php7.0-gd
apt-get install php7.0-memcache php7.0-apcu php7.0-apcu-bc
```

## Configuration (see related files in this repo conf/debian/8-jessie)

```bash
# set env-var for dev-helper conf dir dor debian 8 jessie
export DEV-HELP-HOME="Mettre ici le chemin absolu du repertoire 'dev-helper'"
export DHCONF_DEB8=${DEV-HELP-HOME}/conf/debian/8-jessie
# opcache
cp ${DHCONF_DEB8}/etc/php/mods-available/opcache.ini /etc/php/mods-available/opcache.ini
# apcu
cp ${DHCONF_DEB8}/etc/php/mods-available/apcu.ini /etc/php/mods-available/apcu.ini
# php.ini
cp ${DHCONF_DEB8}/etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini
cp ${DHCONF_DEB8}/etc/php/7.0/cli/php.ini /etc/php/7.0/cli/php.ini
```

## Restart Apache

```bash
/etc/init.d/apache2 restart
```
