# PHP 7.0 Install Instructions With PHPBREW

## Lister version disponibles

```bash
$ phpbrew update
$ phpbrew known
```

À l'heure où j'écris ces lignes voici le resultat de la dernière commande :

```bash
7.0: 7.0.4, 7.0.3, 7.0.2, 7.0.1, 7.0.0 ...
5.6: 5.6.19, 5.6.18, 5.6.17, 5.6.16, 5.6.15, 5.6.14, 5.6.13, 5.6.12 ...
5.5: 5.5.33, 5.5.32, 5.5.31, 5.5.30, 5.5.29, 5.5.28, 5.5.27, 5.5.26 ...
5.4: 5.4.45, 5.4.44, 5.4.43, 5.4.42, 5.4.41, 5.4.40, 5.4.39, 5.4.38 ...
You can run `phpbrew update` to get a newer release list.
```

La dernière version est la **7.0.4**


## Install de la dernière version avec les extension necessaires et/ou utiles

```bash
phpbrew install 7.0.4 +default+dbs-pgsql+iconv+mcrypt+intl+debug+dba+ftp +opcache -- --enable-opcache
```

On installe tous les drivers dbs mais pas postgre ni mongodb

## Switch to PHP-7.0.4 et Verifier l'installation

```bash
$ phpbrew switch 7.0.4
$ php -v

PHP 7.0.4 (cli) (built: Mar 10 2016 17:24:42) ( NTS DEBUG )
Copyright (c) 1997-2016 The PHP Group
Zend Engine v3.0.0, Copyright (c) 1998-2016 Zend Technologies

```

## Installer l'extension GD

Localiser la bibliothèque gd :

```bash
$ sudo updatedb
$ locate gd.h
```

Chez moi la rèponse est : /usr/lib/x86_64-linux-gnu/gd.h

Installer l'extension en fournissant le chemin d'accès :

```bash
$ export MYLIBDIR='/usr/lib/x86_64-linux-gnu'
$ phpbrew ext install gd -- --with-gd="$MYLIBDIR" --with-png-dir="$MYLIBDIR" --with-jpeg-dir="$MYLIBDIR" --with-freetype-dir="$MYLIBDIR" --with-xpm-dir="$MYLIBDIR"
```

## Installer les extensions de cache

```bash
### Zend OPCache ###
$ phpbrew ext install opcache

### APCU ###
$ phpbrew ext install apcu
$ phpbrew ext install github:krakjoe/apcu-bc

### MEMCACHED ###
# https://github.com/phpbrew/phpbrew/wiki/TroubleShooting
# You can install them by pointing extension installer to particular repository and branch
# like: phpbrew ext install <repository_address> <branch_name>
# As for the time of writing this, memcached can be installed with:
$ phpbrew ext install https://github.com/php-memcached-dev/php-memcached php7 -- --disable-memcached-sasl
```

## Utiliser le Serveur Embarqué PHP et pas apache !
```bash
# Exemple pour Symfony :
$ php app/console server:start
```

