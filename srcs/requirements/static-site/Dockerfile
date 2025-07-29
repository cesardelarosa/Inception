# Set base image
FROM debian:bookworm-slim

# Install NGINX and Pandoc
RUN apt-get update && apt-get install -y nginx pandoc

# Create the web root
RUN mkdir -p /var/www/html

# Copy the CSS style into the web root
COPY ./tools/github-style.css /var/www/html/style.css

# Copy the README.md from the local tools directory
COPY ./tools/README.md /README.md

# Convert README.md to index.html using Pandoc
RUN pandoc --standalone --css style.css \
     --metadata pagetitle="Inception Project" \
     -V body-class=markdown-body \
     -f gfm -t html \
     -o /var/www/html/index.html \
     --wrap=none \
     -c style.css \
     /README.md

# Expose port 80 (inside the container)
EXPOSE 80

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
