#!/bin/bash

# Ownership and startup block
chown -R $FTP_USER:$FTP_USER /var/www/html
chmod -R 755 /var/www/html

exec /usr/sbin/vsftpd /etc/vsftpd.conf
