#!/bin/bash

# Initialize data directory. Insecure means no root password as this is set later in the process.
echo "INFO - Preparing data directory for database start"
mysqld --initialize-insecure --user=mysql
echo "INFO - Data directory initialized"
service mysql start

configure-mysql.sh

if [ $? != 0 ]; then
    exit 1
fi

# Grap the generated passsword for the system user inside /etc/mysql/debian.cnf.
password=$(awk '/^password/ {print $3; exit}' /etc/mysql/debian.cnf)

# This user is used by commands such as start, status, restart, stop etc. can be seen inside /etc/init.d/mysql
mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "CREATE USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '"$password"';
        GRANT ALL ON *.* TO 'debian-sys-maint'@'localhost';"

service mysql restart

echo "INFO - Server ready"

tail -f /var/log/mysql/error.log
