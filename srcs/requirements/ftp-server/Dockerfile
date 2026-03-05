# Set base image
FROM debian:bookworm-slim

# Install vsftpd
RUN apt-get update && apt-get install -y vsftpd

# Create directory required for vsftpd
RUN mkdir -p /var/run/vsftpd/empty

# Copy vsftpd configuration
COPY ./tools/vsftpd.conf /etc/vsftpd.conf

# Entrypoint setup
COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Arguments for user creation, passed from docker-compose.yml
ARG FTP_USER
ARG FTP_PASS

# Enviroment variable for bash
ENV FT_USER=${FTP_USER}

# Create user, set password, and define home directory
RUN useradd -m -d /var/www/html ${FTP_USER} && \
    echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# Expose FTP control and passive ports
EXPOSE 21
EXPOSE 21100-21110

# Run vsftpd
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd.conf"]

# Entrypoint
ENTRYPOINT ["entrypoint.sh"]
