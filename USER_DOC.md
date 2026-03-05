# Inception: User Documentation

Welcome to the **Inception** project user guide. This document explains in clear and simple terms how to operate the services provided by this stack.

## 1. Provided Services
This stack deploys a robust web infrastructure including the following core services:
- **Nginx & WordPress:** A fully functional WordPress website served over HTTPS by an Nginx reverse proxy.
- **MariaDB:** The relational database storing all the site's data.
- **Redis:** An in-memory cache to speed up the WordPress performance.
- **Adminer:** A web-based database management tool.
- **Static Site:** A lightweight custom static webpage.
- **FTP Server:** File Transfer Protocol access to manage website files directly.
- **Portainer:** A visual interface to manage Docker containers and infrastructure.

## 2. Managing the Project
You can easily control the project lifecycle using the provided `Makefile`.

* **To start the project:**
  Open your terminal in the root directory and run:
  ```bash
  make up
  ```
  This will build and start all the services in the background.

* **To stop the project:**
  Run the following command:
  ```bash
  make down
  ```
  This gracefully stops the services without deleting any persistent data.

* **To clean the project (preserving data):**
  If you want to remove the containers and the cached Docker images but keep your WordPress site and Database intact, run:
  ```bash
  make clean
  ```

* **To securely reboot the host machine:**
  If you need to reboot the server, use this command to ensure containers are stopped safely before the reboot:
  ```bash
  make restart
  ```

* **To completely wipe the project (Total Reset):**
  If you wish to brutally remove all containers, networks, Docker caches, and **erase all persistent data in the host**, run:
  ```bash
  make fclean
  ```

## 3. Accessing the Services
Once started (using `make up`), you can access the services through your web browser or FTP client:

* **Main Website (WordPress):**
  Navigate to: `https://cde-la-r.42.fr` (Ensure you accept the self-signed SSL certificate).
* **Static Website:**
  Navigate to: `http://localhost:8000` (or `http://cde-la-r.42.fr:8000`)
* **Adminer (Database Management):**
  Navigate to: `http://localhost:8080` (or `http://cde-la-r.42.fr:8080`)
* **Portainer (Docker Management):**
  Navigate to: `https://localhost:9443` (or `https://cde-la-r.42.fr:9443`)
* **FTP Access:**
  Connect to `ftp://localhost` or `ftp://cde-la-r.42.fr` on port `21` using an FTP client like FileZilla.

## 4. Locating and Managing Credentials
For security reasons, all sensitive credentials (passwords, usernames, database names) are stored in an environment configuration file named `.env`.
* **Where is it?** This file must be located at `srcs/.env`.
* **How to manage it?** You must edit this file to change passwords or usernames. Since this file is explicitly ignored by `.gitignore` (by best practices), it will not be committed to Git. If there is a `.env.example` file, use it as a template for which variables need configuring.

## 5. Checking Service Status
To ensure that all services are running correctly, you have a few options:
* **Docker Logs:**
  You can watch the live terminal output for all services by running:
  ```bash
  make logs
  ```
* **Docker Commands:**
  To see a list of running containers and their status, run your terminal:
  ```bash
  docker ps
  ```
* **Portainer Interface:**
  Log into the Portainer web panel at `https://cde-la-r.42.fr:9443` for a complete visual dashboard of container health, logs, and statistics.
