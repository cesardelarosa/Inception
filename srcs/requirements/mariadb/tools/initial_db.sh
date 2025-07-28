#!/bin/bash

# Only run setup if the database directory doesn't exist
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then

    service mariadb start
    sleep 2

    # Run SQL commands to secure installation and create DB and users
    mysql -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        FLUSH PRIVILEGES;
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # Use mysqladmin for a clean shutdown
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

# Execute the Dockerfile's CMD
exec "$@"
