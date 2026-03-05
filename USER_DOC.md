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

> **Note:** The WordPress site is exclusively served over HTTPS (port 443). HTTP connections on port 80 are not available by design. You should always use `https://` when accessing the main site.

## 4. Working with WordPress

### Browsing the Site
Simply open `https://cde-la-r.42.fr` in your browser. Any visitor can browse the published posts and pages.

### Adding Comments
Navigate to any published post. At the bottom of the post, you will find a comment form. Fill in the required fields and submit to post a comment.

### Accessing the Administration Panel
1. Navigate to `https://cde-la-r.42.fr/wp-admin`.
2. Log in using the administrator credentials defined in your `.env` file (`WP_ADMIN_USER` and `WP_ADMIN_PASSWORD`).
3. From the dashboard, you can create or edit posts/pages, manage comments, install themes, and configure the site.

### Editing a Page
1. From the WordPress admin dashboard, go to **Pages** on the left sidebar.
2. Click on any existing page title (e.g., "Sample Page") to open the editor.
3. Make your changes in the editor.
4. Click the **Update** button (top-right) to publish the changes.
5. Visit the page URL on the public site to confirm the changes are visible.

### Using WP-CLI
For advanced users, the WordPress container ships with **WP-CLI**, a command-line interface for managing WordPress:
```bash
# List all registered users
docker exec -it wordpress wp user list --allow-root

# List installed plugins and their status
docker exec -it wordpress wp plugin list --allow-root

# Create a new post directly from the terminal
docker exec -it wordpress wp post create --post_title="Hello World" --post_status=publish --allow-root

# List all existing posts
docker exec -it wordpress wp post list --allow-root
```

## 5. Working with the FTP Server
The FTP server provides direct file-level access to the WordPress installation files. This is useful for uploading themes, plugins, or custom files.

### Connecting via Interactive FTP
```bash
ftp cde-la-r.42.fr
```
When prompted, enter your FTP credentials (the `FTP_USER` and `FTP_PASS` defined in `.env`). Once connected, you can use standard FTP commands:

```
ls                    # List files in the current directory
cd wp-content         # Navigate into the wp-content folder
cd uploads            # Navigate into the uploads folder
put myfile.txt        # Upload a file from your local machine
get wp-config.php     # Download a file to your local machine
mkdir new-folder      # Create a new directory
delete old-file.txt   # Remove a file
bye                   # Disconnect from the server
```

### Using curl for Quick File Transfers
If you prefer non-interactive file transfers, `curl` can be used:
```bash
# Upload a local file to the WordPress root
curl -T localfile.txt ftp://cde-la-r.42.fr/ --user <FTP_USER>:<FTP_PASS>

# Download a remote file
curl ftp://cde-la-r.42.fr/wp-config.php --user <FTP_USER>:<FTP_PASS> -o downloaded.php

# List the contents of a remote directory
curl ftp://cde-la-r.42.fr/wp-content/ --user <FTP_USER>:<FTP_PASS>
```

## 6. Working with Adminer
Adminer provides a visual interface to interact with the MariaDB database directly from the browser.

### Connecting to the Database
1. Open `http://localhost:8080` in your browser.
2. Fill in the login form:
   - **System:** MySQL
   - **Server:** `mariadb`
   - **Username:** The value of `MYSQL_USER` from your `.env` file.
   - **Password:** The value of `MYSQL_PASSWORD` from your `.env` file.
   - **Database:** The value of `MYSQL_DATABASE` from your `.env` file.
3. Click **Login** to enter the management panel.

From here you can browse tables (such as `wp_posts`, `wp_users`, and `wp_comments`), execute SQL queries, and export or import data.

## 7. Working with Redis
Redis runs as a background caching layer and requires no direct user interaction under normal circumstances. To verify it is performing correctly:
```bash
# Verify the Redis server is responding
docker exec -it redis redis-cli ping
# Expected response: PONG

# Check the number of cached keys
docker exec -it redis redis-cli DBSIZE

# Check connected clients (WordPress should appear as a client)
docker exec -it redis redis-cli info clients

# Verify the Redis plugin status from WordPress
docker exec -it wordpress wp redis status --allow-root
# Expected: Status: Connected
```

## 8. Working with Portainer
Portainer provides a full visual dashboard for managing your Docker environment.

1. Navigate to `https://localhost:9443`.
2. On first access, you will be prompted to create an administrator account.
3. Select the **Local** Docker environment.
4. From the main panel you can monitor the running containers, inspect volumes, review networks, read container logs, and restart or stop services individually.

## 9. Locating and Managing Credentials
For security reasons, all sensitive credentials (passwords, usernames, database names) are stored in an environment configuration file named `.env`.
* **Where is it?** This file must be located at `srcs/.env`.
* **How to manage it?** You must edit this file to change passwords or usernames. Since this file is explicitly ignored by `.gitignore` (by best practices), it will not be committed to Git. If there is a `.env.example` file, use it as a template for which variables need configuring.

## 10. Checking Service Status
To ensure that all services are running correctly, you have a few options:
* **Docker Logs:**
  You can watch the live terminal output for all services by running:
  ```bash
  make logs
  ```
* **Service Status:**
  To get a quick overview of all containers, their state, and mapped ports:
  ```bash
  docker compose -f srcs/docker-compose.yml ps
  ```
* **Individual Container Status:**
  To check whether a specific service is running:
  ```bash
  docker compose -f srcs/docker-compose.yml ps nginx
  docker compose -f srcs/docker-compose.yml ps wordpress
  docker compose -f srcs/docker-compose.yml ps mariadb
  ```
* **Portainer Interface:**
  Log into the Portainer web panel at `https://cde-la-r.42.fr:9443` for a complete visual dashboard of container health, logs, and statistics.
