# Set base image
FROM debian:bookworm-slim

# Install PHP-FPM, extensions, and other tools
RUN apt-get update && \
    apt-get install -y php8.2-fpm php8.2-mysql curl wget && \
    rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on a network port
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Install wp-cli (WordPress Command-line Interface)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy the configuration script
COPY ./tools/configure-wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/configure-wp.sh

# Set working directory
WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "configure-wp.sh" ]

# Run php-fpm in the foreground
CMD [ "php-fpm8.2", "-F" ]
