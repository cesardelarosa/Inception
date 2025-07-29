# Set base image
FROM debian:bookworm-slim

# Install Redis server
RUN apt-get update && apt-get install -y redis-server

# Copy custom Redis configuration
COPY ./tools/redis.conf /etc/redis/redis.conf

# Expose Redis port
EXPOSE 6379

# Run Redis server with the custom config
CMD ["redis-server", "/etc/redis/redis.conf"]
