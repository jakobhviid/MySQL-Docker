# How to use
A docker-compose file have been provided below as an example.

```
version: '3'

services:
  mysql:
    image: omvk97/mysql
    container_name: mysql
    restart: always
    ports:
      - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_USER: elon
      MYSQL_PASSWORD: musk
      MYSQL_DATABASE: tesla

```

Three out of the four environment variables seen in this docker-compose file are required. `MYSQL_ROOT_PASSWORD`, `MYSQL_USER` and `MYSQL_PASSWORD`. These three variables will setup a user for outside connections (elon) and change root password for root user on a local connection.

# Configurations
#### Required Configurations

- `MYSQL_ROOT_PASSWORD:` Root user password for administrative access. If you need to grant privileges, create other databases or other administrative tasks see ([Root User](#root-user))
</br>

- `MYSQL_USER:` Default user for mysql, used in connection strings when connecting to the database. **Note:** This user will not have any privileges for administrative tasks. This user will only have access to one database if `MYSQL_DATABASE` has been provided.
</br>

- `MYSQL_PASSWORD:` Default password for `MYSQL_USER`, used in connection strings when connecting to the database.

#### Non required configurations

- `MYSQL_DATABASE:` Initializes a database so you can start using this image out of the box. This database is default only accessible by local root user and the provided `MYSQL_USER` with all privileges. 
</br>

- TODO, THIS IS NOT WORKING CORRECTLY YET `MYSQL_REMOTE_ROOT_IP_ADDRESS:` The root user is by default only accessible from within the container. This variabel will allow remote root access. This is unsafe to do and is not advised to do.




