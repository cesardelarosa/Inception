# Set base image
FROM debian:bookworm-slim

# Install vsftpd
RUN apt-get update && apt-get install -y vsftpd

# Copy vsftpd configuration
COPY ./tools/vsftpd.conf /etc/vsftpd.conf

# Arguments for user creation, passed from docker-compose.yml
ARG FTP_USER
ARG FTP_PASS

# Create user, set password, and define home directory
RUN useradd -m -d /var/www/html ${FTP_USER} && \
    echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# Expose FTP control and passive ports
EXPOSE 21
EXPOSE 21100-21110

# Run vsftpd
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd.conf"]
