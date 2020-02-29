# How to use

A docker-compose file have been provided below as an example.

```
version: '3'

services:
  mysql:
    image: cfei/mysql
    container_name: mysql
    restart: always
    ports:
      - 3306:3306
    volumes:
      - ./data:/var/lib/mysql
      - ./logs:/var/logs/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_USER: elon
      MYSQL_PASSWORD: musk
      MYSQL_DATABASE: tesla

```

Three out of the four environment variables seen in this docker-compose file are required. `MYSQL_ROOT_PASSWORD`, `MYSQL_USER` and `MYSQL_PASSWORD`. These three variables will setup a user for outside connections (elon) and change the password for root user on a local connection.

# Configurations

**Note:** These environment variables only take effect when the container starts up the first time. If you want to change some of these settings you can manually change it with root user or remove container from your system and build again.

#### Required Configurations

- `MYSQL_ROOT_PASSWORD`: Root user password for administrative access. If you need to grant privileges, create other databases or other administrative tasks see ([Root User](#root-user))
  </br>

- `MYSQL_USER`: Default user for mysql, used in connection strings when connecting to the database. **Note:** This user will not have any privileges for administrative tasks. This user will only have access to one database if `MYSQL_DATABASE` has been provided.
  </br>

- `MYSQL_PASSWORD`: Default password for `MYSQL_USER`, used in connection strings when connecting to the database.

#### Non required configurations

- `MYSQL_DATABASE`: Initializes a database so you can start using this image out of the box. This database is default only accessible by local root user and the provided `MYSQL_USER` with all privileges.
  </br>

- `MYSQL_REMOTE_ROOT_IP_ADDRESS`: The root user is by default only accessible from within the container. This variable will allow remote root access. This is unsafe to do and is not advised to do, but can be useful in some situations.

# Volumes

- `/var/lib/mysql`: The data directory contains a lot of information. It stores files needed for mysql to run and the data written to the database itself. It is therefore very important for container recreation.

- `var/logs/mysql`: By default mysql only writes in one file in this directory (errors.log). If this is not sufficient logging contact repository creator.
