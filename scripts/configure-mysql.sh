#!/bin/bash

# test if environment variables have changed
configuration_info_path=/var/lib/mysql/configuration_info

# test if container has been run before and therefor init configuration should not be done again. See end of script to see creation of this file
if [[ $(cat "$configuration_info_path") == "True" ]]; then
    echo "INFO - Configuration has been done before, exiting configuration"
    exit 0
fi

# ------ configuration file setup ------

if [ -z "$MYSQL_PORT" ]; then
    MYSQL_PORT=3306
    echo "INFO - Missing environment variabel MYSQL_PORT, using default" "$MYSQL_PORT"
fi

echo -e "\nport=$MYSQL_PORT" >>/etc/mysql/mysql.conf.d/mysqld.cnf

# ------ essential environment variables test ------

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo -e "\e[1;31mERROR - Missing essential environment variabel MYSQL_ROOT_PASSWORD \e[0m"
    exit 1
fi

if [ -z "$MYSQL_USER" ]; then
    echo -e "\e[1;31mERROR - Missing essential environment variabel MYSQL_USER \e[0m"
    exit 1
fi

if [ -z "$MYSQL_PASSWORD" ]; then
    echo -e "\e[1;31mERROR - Missing essential environment variabel MYSQL_PASSWORD \e[0m"
    exit 1
fi

# ------ root access ------

if ! [ -z "$MYSQL_REMOTE_ROOT_IP_ADDRESS" ]; then
    # simple test for correct IP-address
    if [[ $MYSQL_REMOTE_ROOT_IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "INFO - MySQL Remote Root is being configured. Please note that this is unsafe to do!"
    else
        echo -e "\e[1;31mERROR - Invalid IP address provided for MYSQL_REMOTE_ROOT_IP_ADDRESS \e[0m"
        exit 1
    fi
    
    # set root password and remote access
    mysql --execute "DROP USER root@localhost;
    FLUSH PRIVILEGES;
    CREATE USER 'root'@'"$MYSQL_REMOTE_ROOT_IP_ADDRESS"' IDENTIFIED BY '"$MYSQL_ROOT_PASSWORD"';
    GRANT ALL ON *.* TO 'root'@'"$MYSQL_REMOTE_ROOT_IP_ADDRESS"' WITH GRANT OPTION;"
else
    # set root password for localhost access
    mysql --execute "DROP USER root@localhost;
    FLUSH PRIVILEGES;
    CREATE USER 'root'@'localhost' IDENTIFIED BY '"$MYSQL_ROOT_PASSWORD"';
    GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
fi

# ------ mysql_user creation ------

mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "CREATE USER IF NOT EXISTS '"$MYSQL_USER"'@'%' IDENTIFIED BY '"$MYSQL_PASSWORD"';" >/dev/null # sending stdout to bit bucket (null device) / supressing warnings

if ! [ -z "$MYSQL_DATABASE" ]; then
    mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "CREATE DATABASE IF NOT EXISTS "$MYSQL_DATABASE";" >/dev/null # sending stdout to bit bucket (null device) / supressing warnings
    mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "GRANT ALL ON "$MYSQL_DATABASE".* TO '"$MYSQL_USER"'@'%';" >/dev/null &&
        echo "INFO - successfully Created database "$MYSQL_DATABASE" with all access to user '"$MYSQL_USER"'"
fi

# ------ Clean up ------

# reload_privilege_tables for changes to take effect
mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "FLUSH PRIVILEGES;" >/dev/null

# remember that configuration has run in this container before and should not be run again
touch $configuration_info_path
echo "True" >>"$configuration_info_path"

echo "INFO - MySQL configuration done!"
