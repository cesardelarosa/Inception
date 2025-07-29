# Set base image
FROM debian:bookworm-slim

# Install NGINX, PHP with MySQL extension, and wget
RUN apt-get update && \
    apt-get install -y nginx php8.2-fpm php8.2-mysql wget && \
    rm -rf /var/lib/apt/lists/*

# Create web root directory
RUN mkdir -p /var/www/html

# Download the latest version of Adminer
RUN wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php

# Copy NGINX configuration
COPY ./tools/nginx.conf /etc/nginx/sites-available/default

# Expose the port we will use
EXPOSE 8080

# Run NGINX and PHP-FPM in the foreground
CMD [ "sh", "-c", "php-fpm8.2 -D && nginx -g 'daemon off;'" ]
