#!/bin/bash

mysqlAdminStatus=$(mysqladmin status)

# if mysqladminstatus is not empty
if ! [[ -z "$mysqlAdminStatus" ]]; then
    mysql --execute "CREATE DATABASE IF NOT EXISTS healthcheck;"

    mysql --execute "CREATE TABLE healthcheck.test (id int PRIMARY KEY);"

    mysql --execute "INSERT INTO healthcheck.test VALUES (1), (2);"

    output=$(mysql --execute "SELECT * FROM healthcheck.test;")

    if [[ -z "$output" ]]; then
        echo "ERROR data test failed"
        exit 1
    fi

    # clean up for next healthcheck
    mysql --execute "DROP DATABASE healthcheck;"
fi

echo " MYSQL SERVER NOT RUNNING PROPERLY "
exit 1
