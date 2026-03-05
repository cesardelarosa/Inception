*This project has been created as part of the 42 curriculum by cde-la-r.*

## Description

The **Inception** project is a system administration exercise aimed at broadening our knowledge of Docker. The primary goal is to set up a small-scale, custom web infrastructure entirely within Docker containers. 

This repository provides a complete deployment for a secure web stack. It configures an Nginx server, a WordPress site (with PHP-FPM), and a MariaDB database, each isolated within its own completely independent container. The containers are linked via a dedicated internal Docker network to ensure secure communication. By completing this project, one solidifies fundamental system administration skills, basic container orchestration, and network configuration concepts.

## Instructions

To build, install, and execute this project, follow these steps:

1. **Prerequisites:** Ensure you have Docker Engine, Docker Compose plugin, and `make` installed on your Linux machine.
2. **Domain Configuration:** Map the local domain `cde-la-r.42.fr` to your local loopback address. You can do this by adding the following line to your `/etc/hosts` file (requires root privileges):
   ```bash
   127.0.0.1 cde-la-r.42.fr
   ```
3. **Environment Secrets:** Create a `.env` file located at `srcs/.env` based on the configuration required by the services. This file should contain the necessary credentials, database names, and passwords.
4. **Execution:** At the root of the repository, execute the following command:
   ```bash
   make
   ```
   This will automatically create the persistent data directories on the host system (`/home/cde-la-r/data/*`), build all custom Docker images, and spin up the containers in detached mode.

*To gracefully stop the services, run `make down`. To perform a complete, destructive reset of the environment (including wiping all data), run `make fclean`. For more detailed operations, refer to `USER_DOC.md` and `DEV_DOC.md`.*

## Project Description

Inception leverages **Docker** to encapsulate each service (Nginx, WordPress, MariaDB, Redis, etc.) into its own independent environment. Rather than relying on pre-built, ready-to-go images like the official `wordpress:latest`, we use custom `Dockerfile`s built from minimalistic OS bases (such as Alpine Linux or Debian). This gives us granular control over the installation, runtime configuration, and security practices of each service. Our `docker-compose.yml` ties these individual nodes into a comprehensive, working network.

### Design Choices and Architectures

#### Virtual Machines vs Docker
- **Virtual Machines (VMs)** virtualize complete hardware, allowing entire operating systems (including their own kernel) to run atop a hypervisor. While they offer robust security isolation, they are inherently heavy, consume significant memory, and are slow to launch.
- **Docker**, on the other hand, relies on OS-level virtualization. Containers share the host machine's kernel but isolate the application processes, filesystems, and network stacks. This makes containers extremely lightweight, highly scalable, and capable of spinning up in fractions of a second.

#### Secrets vs Environment Variables
- **Secrets** (e.g., Docker Swarm Secrets or Kubernetes Secrets) are securely stored, encrypted, and injected securely into containers at runtime as temporary memory-backed files. They are significantly safer and prevent credential leakage.
- **Environment Variables** are simpler to configure (we use a `.env` file to inject them) but are considered a less secure paradigm because they might be exposed if an attacker runs a `docker inspect` command or via application crash logs. In this project, we rely on environment variables for simplicity but strictly omit the `.env` file from version control to prevent repository leaks.

#### Docker Network vs Host Network
- **Host Network** removes the network isolation entirely off the container, binding its processes directly to the host's IP and ports. While slightly more performant, it leads to port conflicts easily and degrades the security of the container.
- **Docker Network** (the bridge networking model we use) isolates the containers into a customized internal subnet. Our containers communicate with one another using an internal DNS provided by Docker (using container names like `mariadb` or `nginx`). The only entryway from the host system is through explicitly published ports, securing internal traffic.

#### Docker Volumes vs Bind Mounts
- **Docker Volumes** are managed directly by the Docker daemon and stored natively inside Docker's internal directories (`/var/lib/docker/volumes/`). They are the easiest way to preserve data across platforms.
- **Bind Mounts** allow you to map a specific, pre-existing absolute path from the host system directly into a container's filesystem. We rely on bind mounts in this project (mounting directories from `/home/cde-la-r/data/` to internal container paths) so that the WordPress files and Database records persist safely and transparently on our host machine, surviving regardless of the container lifecycle.

## Resources

- [Docker Official Documentation](https://docs.docker.com/) — The primary manual for constructing Dockerfiles, managing networks, and writing Docker Compose descriptors.
- [Nginx Official Documentation](https://nginx.org/en/docs/) — Crucial for understanding how to properly configure TLS certificates and reverse proxy routing.
- [WordPress Developer Resources](https://developer.wordpress.org/cli/commands/) — For installing, automating, and tweaking WordPress via WP-CLI without GUI intervention.
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/) — Reference for database initialization and user privilege granting commands.

**Use of AI:**
Artificial Intelligence (LLMs) was used as an assistant throughout the lifecycle of this project. It helped debug complex Bash script behaviors and writing .md files, clarified confusing Docker build errors, and answered targeted questions regarding optimal software configurations. No core application structure or mandatory scripts were wholesale generated without complete verification and understanding from the developer.
