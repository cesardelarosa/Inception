# Inception: Developer Documentation

This document explains the internal setup and architecture for developers maintaining or extending the **Inception** project. 

## 1. Setting Up the Environment from Scratch

### Prerequisites
1. **Docker Engine & Docker Compose:** Must be installed on the host machine.
2. **Make:** The `make` utility must be installed to use the automated building scripts.
3. **Hosts file modification:** To map the domain `cde-la-r.42.fr` to your local machine, add the following line to your `/etc/hosts` file (requires `sudo`):
   ```
   127.0.0.1 cde-la-r.42.fr
   ```

### Configuration Files and Secrets
All container configurations are stored in the `srcs/` directory. Each service has its own folder containing a specific `Dockerfile` and necessary scripts (e.g., `tools/` or `conf/`).

The project handles secrets through a `.env` file located at `srcs/.env`. 
**Important:** You must manually create the `srcs/.env` file from a template before launching the project. It should contain passwords, usernames, database names, domain names, and email parameters needed for WordPress, MariaDB, and the FTP server.

## 2. Building and Launching the Project
The project exclusively uses a `Makefile` situated at the root of the repository to interact with Docker Compose.

* **Build & Start:** 
  ```bash
  make  # or `make up`
  ```
  This command creates the required host-machine data directories, builds all the custom Docker images inside `srcs/requirements/`, and boots the containers up in detached mode via `docker compose up --build -d`.

* **Force a Full Restart:**
  ```bash
  make re
  ```
  It first cleans the environment and then rebuilds the structure entirely.

## 3. Service Architecture

### Container Images
Every service is built from its own `Dockerfile` located in `srcs/requirements/<service>/`. All custom images use `debian:bookworm-slim` as the base, providing a lightweight and consistent foundation across the stack.

Each Dockerfile follows the same structure:
1. `FROM debian:bookworm-slim` — sets the base image.
2. `RUN` instructions to install packages and configure the service.
3. `COPY` to inject configuration files and entrypoint scripts from the `tools/` subdirectory.
4. `EXPOSE` to declare the service port.
5. `ENTRYPOINT` / `CMD` to define the foreground process.

To review all the base images in use:
```bash
grep -rn "^FROM" srcs/requirements/*/Dockerfile
```

### Service Communication
The `docker-compose.yml` organizes the startup order via `depends_on` directives:
- **MariaDB** starts first (no dependencies).
- **Redis** starts independently.
- **WordPress** waits for MariaDB and Redis.
- **Nginx** waits for WordPress.
- Bonus services (Adminer, FTP, etc.) depend on their relevant upstream services.

WordPress connects to MariaDB using the compose service name as hostname (`mariadb:3306`), and Nginx forwards PHP requests to the WordPress container at `wordpress:9000` via FastCGI. This internal DNS resolution is powered by Docker's built-in networking.

### TLS Configuration
The Nginx container generates a self-signed SSL certificate at build time using OpenSSL:
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 ...
```
The Nginx configuration enforces TLS by only listening on port 443 with `ssl_protocols TLSv1.2 TLSv1.3`. No HTTP listener on port 80 is configured, so unencrypted connections are rejected at the transport level. To verify the active TLS protocol from the command line:
```bash
echo | openssl s_client -connect cde-la-r.42.fr:443 2>/dev/null | grep "Protocol"
```

## 4. Networking

### Docker Network
All services communicate over a single user-defined bridge network named `inception`, declared in `docker-compose.yml`:
```yaml
networks:
  inception:
    driver: bridge
```
Each service is attached to this network, enabling container-to-container communication via service name resolution (e.g., WordPress resolves `mariadb` to the MariaDB container's IP automatically).

This is preferred over the default bridge network because user-defined bridge networks provide automatic DNS resolution between containers, proper isolation from unrelated containers on the host, and a cleaner separation of concerns.

### Inspecting the Network
To list the available Docker networks:
```bash
docker network ls
```
This will show the project's network (typically named `srcs_inception` based on the compose project name). To inspect which containers are connected to it and view their assigned IP addresses:
```bash
docker network inspect srcs_inception
```
The output lists every connected container, its IPv4 address within the network, and the network's gateway and subnet configuration. This is useful for debugging connectivity issues between services.

### Port Mapping
External access is provided only through explicit port mappings in `docker-compose.yml`. Internal service ports remain inaccessible from the host unless explicitly mapped:

| Service | Host Port | Container Port | Protocol |
|---------|-----------|----------------|----------|
| Nginx | 443 | 443 | HTTPS |
| Adminer | 8080 | 8080 | HTTP |
| Static Site | 8000 | 80 | HTTP |
| FTP Server | 21 | 21 | FTP Control |
| FTP Server | 21100-21110 | 21100-21110 | FTP Passive |
| Portainer | 9443 | 9443 | HTTPS |

Services like MariaDB (3306), Redis (6379), and WordPress/PHP-FPM (9000) are intentionally **not** exposed to the host. They are only accessible within the `inception` network.

## 5. Volumes and Persistent Storage
Data persistence is achieved via Docker Volumes defined in `srcs/docker-compose.yml`. Unlike standard unnamed volumes, this project binds volumes directly to specific host system directories to guarantee data survival between container destruction/recreation.

### Volume Definitions

* **Database (MariaDB):**
  - **Docker Volume:** `db_data`
  - **Container Path:** `/var/lib/mysql`
  - **Host Directory:** `/home/cde-la-r/data/db`

* **WordPress Files:**
  - **Docker Volume:** `wp_files`
  - **Container Path:** `/var/www/html`
  - **Host Directory:** `/home/cde-la-r/data/wordpress`

* **Portainer Data:**
  - **Docker Volume:** `portainer_data`
  - **Container Path:** `/data`

By utilizing these host bind mounts, modifying website files via FTP or updating WordPress through its panel immediately reflects on the host machine filesystem, ensuring total data persistence even when the container is taken down using `docker compose down`.

### Inspecting Volumes
To list all Docker volumes managed by the project:
```bash
docker volume ls
```
To examine the details of a specific volume, including its mountpoint on the host system:
```bash
docker volume inspect srcs_db_data
docker volume inspect srcs_wp_files
```
The output includes the `device` field, which maps to the physical path on the host (`/home/cde-la-r/data/db` or `/home/cde-la-r/data/wordpress`). You can browse these directories directly on the host to inspect or back up the raw data files:
```bash
ls /home/cde-la-r/data/db/
ls /home/cde-la-r/data/wordpress/
```

### How Persistence Works Across Reboots
Because the volumes are bound to host directories, all data survives container restarts, `docker compose down`, and even full system reboots. After a reboot, simply run `make up` to recreate the containers — they will automatically reattach to the existing data in the host directories without any data loss.

## 6. Managing Containers and Debugging

### Makefile Commands
Use the `Makefile` commands for day-to-day administration:
* `make clean`: Performs `make down`, and removes cached images created by `docker compose`. Host data is preserved.
* `make restart`: Gracefully brings down the services and issues a reboot command to the host OS.
* `make fclean`: Performs `make clean`, brutally removes any lingering containers, all Docker cache/volumes, and deletes the actual host data folders (`/home/cde-la-r/data/*`). **Warning: This performs a total wipe of persistent data.**
* `make logs`: Attaches to the stdout of all running containers.

### Direct Docker Commands
For more granular control, you can use standard Docker and Docker Compose commands:

```bash
# View running containers and their health
docker compose -f srcs/docker-compose.yml ps

# View logs for a specific service
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs nginx

# Open an interactive shell inside a container for debugging
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

# List all Docker images built by the project
docker images
```

### Accessing the MariaDB Database
To open an interactive MySQL session for inspecting or debugging the database:
```bash
# Connect as root
docker exec -it mariadb mysql -u root -p
# (Enter the MYSQL_ROOT_PASSWORD when prompted)

# Or connect directly as the WordPress database user
docker exec -it mariadb mysql -u <MYSQL_USER> -p <MYSQL_DATABASE>
```
Once inside the MySQL prompt, useful commands include:
```sql
SHOW DATABASES;
USE <database_name>;
SHOW TABLES;
SELECT user_login, user_email FROM wp_users;
SELECT ID, post_title, post_status FROM wp_posts LIMIT 10;
SELECT * FROM wp_comments;
EXIT;
```

### Verifying Redis Cache Health
To confirm that the Redis cache is active and serving WordPress:
```bash
# Ping the Redis server
docker exec -it redis redis-cli ping
# Expected: PONG

# Check memory usage
docker exec -it redis redis-cli info memory

# Check how many keys are currently cached
docker exec -it redis redis-cli DBSIZE

# Check connected clients
docker exec -it redis redis-cli info clients

# Verify from WordPress that the Redis plugin is active
docker exec -it wordpress wp redis status --allow-root
```

### Testing FTP Connectivity
To verify that the FTP server is accessible and serving the correct file tree:
```bash
# List the FTP root directory contents via curl
curl ftp://cde-la-r.42.fr/ --user <FTP_USER>:<FTP_PASS>

# The output should match the WordPress installation files
docker exec -it wordpress ls /var/www/html/
```

## 7. Adding or Modifying a Service
To add a new service to the stack:
1. Create a new directory under `srcs/requirements/<service-name>/`.
2. Write a `Dockerfile` using `debian:bookworm-slim` as the base image.
3. Add a `tools/` subdirectory for any configuration files or entrypoint scripts.
4. Register the service in `srcs/docker-compose.yml`, attaching it to the `inception` network and defining any required volumes or port mappings.
5. If the service needs credentials, add the corresponding variables to `srcs/.env` and reference them via `env_file: .env` in the compose definition.
6. Run `make re` to rebuild the full stack with the new service included.
