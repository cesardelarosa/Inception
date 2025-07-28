# Makefile for the Inception project

# Variables
COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE_CMD = docker compose -f $(COMPOSE_FILE)
DOMAIN_NAME = cde-la-r.42.fr

# Data directories that need to exist on the host
DATA_PATH_DB = /home/cde-la-r/data/db
DATA_PATH_WP = /home/cde-la-r/data/wordpress

# Colors for output messages
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
RESET = \033[0m

# Default rule, executed when running 'make'
all: up

# Create directories, build images, and start services in detached mode
up:
	@echo "$(BLUE)Creating data directories if they don't exist...$(RESET)"
	@mkdir -p $(DATA_PATH_DB) $(DATA_PATH_WP)
	@echo "$(BLUE)Building and starting services in detached mode...$(RESET)"
	@$(COMPOSE_CMD) up --build -d
	@echo "$(GREEN)✅ Inception is up and running! Access it at: https://$(DOMAIN_NAME)$(RESET)"

# Build images without starting the services
build:
	@echo "$(BLUE)Building all service images...$(RESET)"
	@$(COMPOSE_CMD) build
	@echo "$(GREEN)Images built successfully.$(RESET)"

# Stop and remove containers and networks
down:
	@echo "$(YELLOW)Stopping and removing containers and networks...$(RESET)"
	@$(COMPOSE_CMD) down
	@echo "$(GREEN)Services stopped successfully.$(RESET)"

# Stop and remove everything, including volumes with data
clean:
	@echo "$(YELLOW)WARNING: Cleaning the environment. All data in volumes will be lost.$(RESET)"
	@$(COMPOSE_CMD) down --volumes
	@echo "$(GREEN)Environment cleaned successfully.$(RESET)"

# Force a full clean and restart of the application
re:
	@make clean
	@make all

# Follow the logs of all running services
logs:
	@echo "$(BLUE)Attaching to logs... Press Ctrl+C to exit.$(RESET)"
	@$(COMPOSE_CMD) logs -f

# Phony targets are rules that are not actual files
.PHONY: all up build down clean re logs
