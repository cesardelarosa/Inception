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

# Stop and remove containers, networks, and base images (preserves host data)
clean: down
	@echo "$(YELLOW)Cleaning the environment. Host data will be preserved.$(RESET)"
	@$(COMPOSE_CMD) down --rmi all
	@echo "$(GREEN)Environment cleaned successfully.$(RESET)"

# Full clean: brutally wipe everything, including docker system and host data
fclean: clean
	@echo "$(YELLOW)WARNING: Deep cleaning the environment. ALL DATA WILL BE LOST...$(RESET)"
	@echo "$(BLUE)Removing docker cache and host directories...$(RESET)"
	-@docker stop $$(docker ps -qa) 2>/dev/null || true
	-@docker rm $$(docker ps -qa) 2>/dev/null || true
	-@docker rmi -f $$(docker images -qa) 2>/dev/null || true
	-@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	-@docker network rm $$(docker network ls -q) 2>/dev/null || true
	@sudo rm -rf $(DATA_PATH_DB)/*
	@sudo rm -rf $(DATA_PATH_WP)/*
	@echo "$(GREEN)Total wipe completed.$(RESET)"

# Restart the host machine securely by stopping services first
restart: down
	@echo "$(YELLOW)Rebooting the host system...$(RESET)"
	@sudo systemctl reboot

# Force a full clean and start completely from scratch
re:
	@make fclean
	@make all

# Follow the logs of all running services
logs:
	@echo "$(BLUE)Attaching to logs... Press Ctrl+C to exit.$(RESET)"
	@$(COMPOSE_CMD) logs -f

# Phony targets are rules that are not actual files
.PHONY: all up build down clean fclean restart re logs
