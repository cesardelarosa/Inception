# Set base image
FROM debian:bookworm-slim

# Install NGINX and Pandoc
RUN apt-get update && apt-get install -y nginx pandoc

# Create the web root
RUN mkdir -p /var/www/html

# Copy the CSS style into the web root
COPY ./tools/github-style.css /var/www/html/style.css

# Copy the entrypoint script
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port 80 (inside the container)
EXPOSE 80

# Run entrypoint script which converts markdown and starts nginx
CMD ["/usr/local/bin/entrypoint.sh"]
