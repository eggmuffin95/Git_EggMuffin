
#!/usr/bin/env bash

# Usage: ./ec2Install.sh [<environment_name>] [<host_name>] [<root_folder_name>]

display_usage() {
	echo "All arguments are mandatory";
	echo -e "\nUsage:\n\t$0 <environment_name> <host_name> <root_folder_name> \n\nWhere \n\t- environment_name: Current environment on which the script is launched (dev |qa | staging | prod)\n\t- host_name: Future API host name ex: dev.aws.bayam.fr\n\t- root_folder_name: specifies the root folder name in which the code will be placed (ex: api-bayam). Web server will read you code in /var/www/bayard/api-bayam\n"
}

if [ $# -le 1 ] || [ $# == "--help" ] || [ $# == "-h" ];
  then
    display_usage
    exit;
fi

if [ -z "$1" ];
  then
    echo "You must specify environment (dev, qa, staging, prod)";
    display_usage
    exit;
fi
if [ -z "$2" ];
  then
    echo "You must specify a hostname (ex: dev.aws.bayam.fr)";
    display_usage
    exit;
fi
if [ -z "$3" ];
  then
    echo "You must specify a root folder name in which the code will be placed (ex: api-bayam). Web server will read you code in /var/www/bayard/api-bayam";
    display_usage
    exit;
fi

ENV=$1
HOST_NAME=$2
ROOT_FOLDER_NAME=$3
ROOT_FOLDER_PATH=/var/www/bayard/${ROOT_FOLDER_NAME}
CURRENT_USER=$SUDO_USER

if [ "$1" == "prod" ];
  then
    FRONT_CONTROLLER="app";
  else
    FRONT_CONTROLLER="app_${ENV}";
fi

sudo mkdir -p ${ROOT_FOLDER_PATH}

apt-get update && apt-get upgrade && apt-get dist-upgrade -y
echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list
wget https://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg
apt-get update


sudo apt-get install -y vim nginx mysql-client php7.0-fpm php7.0-cli php7.0-common php7.0-mysql git php7.0-intl curl php7.0-curl
sudo chown -R admin:www-data ${ROOT_FOLDER_PATH}


# Set run-as user for PHP5-FPM processes to user/group "admin/www-data"
# to avoid permission errors from apps writing to files
sudo sed -i "s/user = www-data/user = admin/" /etc/php/7.0/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = www-data/" /etc/php/7.0/fpm/pool.d/www.conf

sudo sed -i "s/listen\.owner.*/listen.owner = www-data/" /etc/php/7.0/fpm/pool.d/www.conf
sudo sed -i "s/listen\.group.*/listen.group = www-data/" /etc/php/7.0/fpm/pool.d/www.conf
# sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" /etc/php/7.0/fpm/pool.d/www.conf

sudo sed -i "s/;date.timezone =.*/date.timezone = Europe\/Paris/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/;date.timezone =.*/date.timezone = Europe\/Paris/" /etc/php/7.0/cli/php.ini


# bash_profile setup
touch /home/${CURRENT_USER}/.bash_profile
cat > /home/${CURRENT_USER}/.bash_profile << EOL
alias ll="ls -l"
alias apiconsole="php ${ROOT_FOLDER_PATH}/live/app/console --env=$ENV"
EOL
source /home/${CURRENT_USER}/.bash_profile

sudo touch /etc/nginx/sites-available/${ROOT_FOLDER_NAME}
cat > /etc/nginx/sites-available/${ROOT_FOLDER_NAME} << EOL
server {
    listen 80;

    server_name ${HOST_NAME};
    root ${ROOT_FOLDER_PATH}/live/web;

    error_log /var/log/nginx/${ROOT_FOLDER_NAME}.error.log;
    access_log /var/log/nginx/${ROOT_FOLDER_NAME}.access.log;

    add_header 'Access-Control-Allow-Origin' '*';
    add_header 'Access-Control-Allow-Credentials' 'true';
    add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS,DELETE,PUT';
    add_header 'Access-Control-Allow-Headers' 'Access-Control-Request-Headers, Access-Control-Allow-Headers, Accept, Origin, X-Requested-With, Authorization, Content-Type, Content-length, Connection';
    add_header 'Access-Control-Expose-Headers'  'Authorization';

    real_ip_header X-Forwarded-For;
		set_real_ip_from 0.0.0.0/0;

    location / {
        if ($http_x_forwarded_proto != 'https') {
          return 301 https://$server_name$request_uri;
        }
        # try to serve file directly, fallback to ${FRONT_CONTROLLER}.php
        try_files \$uri /${FRONT_CONTROLLER}.php\$is_args\$args;
    }

    location ~ ^/${FRONT_CONTROLLER}\.php(/|\$) {
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)\$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOL

sudo touch /etc/nginx/sites-available/${ROOT_FOLDER_NAME}.maintenance
cat > /etc/nginx/sites-available/${ROOT_FOLDER_NAME}.maintenance << EOL
server {
    listen 80;

    server_name ${HOST_NAME};
    root ${ROOT_FOLDER_PATH}/live/web;

    error_log /var/log/nginx/${ROOT_FOLDER_NAME}.error.log;
    access_log /var/log/nginx/${ROOT_FOLDER_NAME}.access.log;

    location / {
	add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS,DELETE,PUT';
        add_header 'Access-Control-Allow-Headers' 'Access-Control-Request-Headers, Access-Control-Allow-Headers, Accept, Origin, X-Requested-With, Authorization, Content-Type, Content-length, Connection';
        add_header 'Access-Control-Expose-Headers'  'Authorization';
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'application/json charset=UTF-8';

        return 503 '{"code": 503, "reason": "Service maintenance."}';
    }
}
EOL

if [ ! -L /etc/nginx/sites-enabled/${ROOT_FOLDER_NAME} ] ;
  then
    sudo ln -s /etc/nginx/sites-available/${ROOT_FOLDER_NAME} /etc/nginx/sites-enabled/${ROOT_FOLDER_NAME}
fi

sudo service nginx restart
sudo service php7.0-fpm restart
