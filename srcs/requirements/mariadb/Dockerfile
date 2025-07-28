# Set base image
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y mariadb-server procps

# Copy custom MariaDB configuration
COPY ./tools/50-server.cnf /etc/mysql/mariadb.conf.d/

# Copy and make executable the entrypoint script
COPY ./tools/initial_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/initial_db.sh

EXPOSE 3306

ENTRYPOINT [ "initial_db.sh" ]

# Default command to run the database server
CMD [ "mysqld_safe" ]
