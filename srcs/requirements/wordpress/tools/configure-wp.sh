#!/bin/bash

# Wait for MariaDB to be ready before proceeding.
# A simple sleep is often enough for this project's scope.
sleep 10

# Setup WordPress if it's not already installed.
# The check is for the existence of the main configuration file.
if [ ! -f "/var/www/html/wp-config.php" ]; then

    wp core download --allow-root

    # Note: dbhost is the service name from docker-compose.yml
    wp config create --dbname=${MYSQL_DATABASE} \
                     --dbuser=${MYSQL_USER} \
                     --dbpass=${MYSQL_PASSWORD} \
                     --dbhost=mariadb:3306 \
                     --allow-root

    wp core install --url=${DOMAIN_NAME} \
                    --title="${WP_TITLE}" \
                    --admin_user=${WP_ADMIN_USER} \
                    --admin_password=${WP_ADMIN_PASSWORD} \
                    --admin_email=${WP_ADMIN_EMAIL} \
                    --skip-email \
                    --allow-root

    wp user create ${WP_USER} ${WP_USER_EMAIL} \
                   --user_pass=${WP_USER_PASSWORD} \
                   --role=author \
                   --allow-root

    # Install and activate Redis cache plugin
    wp plugin install redis-cache --activate --allow-root

    # Configure Redis connection and enable the object cache drop-in
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root
    wp redis enable --allow-root

    # Set correct ownership for all files after they are created
    chown -R www-data:www-data /var/www/html
fi

# Execute the Dockerfile's CMD to start php-fpm
exec "$@"
