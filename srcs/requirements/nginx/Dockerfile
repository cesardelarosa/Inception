# Set base image
FROM debian:bookworm-slim

# Install nginx and openssl
RUN apt-get update && apt-get install -y nginx openssl

# Create directory for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=student/CN=cde-la-r.42.fr"

# Copy the nginx configuration file
COPY ./tools/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
