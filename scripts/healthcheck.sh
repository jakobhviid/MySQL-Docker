#!/bin/bash

mysqlAdminStatus=$(mysqladmin --password="$MYSQL_ROOT_PASSWORD" status)

# if mysqladminstatus is not empty
if ! [[ -z "$mysqlAdminStatus" ]]; then
    mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "CREATE DATABASE IF NOT EXISTS healthcheck;"

    mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "CREATE TABLE healthcheck.test (id int PRIMARY KEY);"

    mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "INSERT INTO healthcheck.test VALUES (1), (2);"

    output=$(mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "SELECT * FROM healthcheck.test;")

    if [[ -z "$output" ]]; then
        echo "ERROR data test failed"
        exit 1
    fi

    # clean up for next healthcheck
    mysql --user=root --password="$MYSQL_ROOT_PASSWORD" --execute "DROP DATABASE healthcheck;"

    exit 0
fi

echo " MYSQL SERVER NOT RUNNING PROPERLY "
exit 1
