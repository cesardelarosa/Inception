# Set base image
FROM debian:bookworm-slim

# Install NGINX
RUN apt-get update && apt-get install -y nginx

# Copy the static website content into the default nginx web root
COPY ./tools/www/ /var/www/html/

# Expose port 80 (inside the container)
EXPOSE 80

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
