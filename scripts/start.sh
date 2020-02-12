#!/bin/bash

service mysql start

configure-mysql.sh

if [ $? != 0 ]; then
    exit 1
fi

service mysql restart

echo "INFO - Server ready"

tail -f /var/log/mysql/error.log
