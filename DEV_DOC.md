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

## 3. Managing Containers and Volumes
Use the `Makefile` commands for day-to-day administration:
* `make clean`: Performs `make down`, and removes cached images created by `docker compose`. Host data is preserved.
* `make restart`: Gracefully brings down the services and issues a reboot command to the host OS.
* `make fclean`: Performs `make clean`, brutally removes any lingering containers, all Docker cache/volumes, and deletes the actual host data folders (`/home/cde-la-r/data/*`). **Warning: This performs a total wipe of persistent data.**
* `make logs`: Attaches to the stdout of all running containers.

Alternatively, you can manually use standard Docker commands:
- Enter a container for debugging: `docker exec -it <container_name> /bin/bash`
- List active volumes: `docker volume ls`
- Check network connections: `docker network inspect inception`

## 4. Where Project Data is Stored and How it Persists
Data persistence is achieved via Docker Volumes defined in `srcs/docker-compose.yml`. Unlike standard unnamed volumes, this project binds volumes directly to specific host system directories to guarantee data survival between container destruction/recreation.

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
