#!/bin/bash

# ------ configuration file setup ------

if [ -z "$MYSQL_PORT" ]; then
    MYSQL_PORT=3306
    echo "INFO - Missing environment variabel MYSQL_PORT, using default " "$MYSQL_PORT"
fi

echo -e "\nport=$MYSQL_PORT" >>/etc/mysql/mysql.conf.d/mysqld.cnf

# ------ essential environment variables test ------

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo -e "\e[1;31mERROR Missing essential environment variabel MYSQL_ROOT_PASSWORD \e[0m"
    exit 1
fi

if [ -z "$MYSQL_USER" ]; then
    echo -e "\e[1;31mERROR Missing essential environment variabel MYSQL_USER \e[0m"
    exit 1
fi

if [ -z "$MYSQL_PASSWORD" ]; then
    echo -e "\e[1;31mERROR Missing essential environment variabel MYSQL_PASSWORD \e[0m"
    exit 1
fi

# ------ root access ------

# set root password for localhost access
mysql --execute "UPDATE USER SET authentication_string = PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User = 'root'"
mysql --execute "UPDATE USER SET PLUGIN='mysql_native_password'"
# disallow remote root access
mysql --execute "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
# remove_anonymous_users
mysql --execute "DELETE FROM mysql.user WHERE User=''"

# ------ mysql_user creation ------

mysql --execute "CREATE USER '"$MYSQL_USER"'@'%' IDENTIFIED BY '"$MYSQL_PASSWORD"';"

if ! [ -z "$MYSQL_DATABASE" ]; then
    mysql --execute "CREATE DATABASE IF NOT EXISTS "$MYSQL_DATABASE""
    mysql --execute "GRANT ALL ON "$MYSQL_DATABASE".* TO '"$MYSQL_USER"'@'%';"
    echo "INFO successfully Created database "$MYSQL_DATABASE" with all access to user '"$MYSQL_USER"'"
fi

# ------ Clean up ------

# reload_privilege_tables for changes to take effect
mysql --execute "FLUSH PRIVILEGES"

echo "INFO - MySQL configuration done!"
