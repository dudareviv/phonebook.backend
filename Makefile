#!make
include environments/docker/.env

ENV					   ?= dev
PREFIX		 			= ${PROJECT_PREFIX}

DOCKER_DIR              = environments/docker
BIN_DOCKER 			    = docker
BIN_DOCKER_COMPOSE 	    = docker-compose
DOCKER_COMPOSE_FILES    = -f docker-compose.yml
SERVICES 				= $(BIN_DOCKER_COMPOSE) $(DOCKER_COMPOSE_FILES)
EXEC                    = $(SERVICES) exec


help:
	@echo "\033[0;33mWelcome to api project\033[0m\n"
	@echo "Project management tool. Please, make sure you have .env file.\n"
	@echo "Usage: \n\
\n\
\033[0m\033[0;32m[Install & Uninstall]\033[0m\n\
\n\
\033[0mmake build                               \033[0m  Build all project.\n\
\033[0mmake rebuild                             \033[0m  Casts make down, make drop, make build.\n\
\033[0mmake drop                                \033[0m  Drop logs and data directories.\n\
\n\
\033[0m\033[0;32m[Running]\033[0m\n\
\n\
\033[0mmake run-dev (alias: up)                 \033[0m  Casts docker-compose up -d.\n\
\033[0mmake run-prod                            \033[0m  Casts docker-compose up -d with Production settings.\n\
\033[0mmake run-test                            \033[0m  Casts docker-compose up -d with Testing settings. This container can run async with dev- or prod- builds\n\
\033[0mmake down                                \033[0m  Casts docker-compose down.\n\
\n\
\033[0m\033[0;32m[Package management]           \033[0m\n\
\n\
\033[0mmake composer-install (alias: i)         \033[0m  Delete composer.lock file and cast composer install.\n\
\n\
\033[0m\033[0;32m[Databases]                    \033[0m\n\
\n\
\033[0mmake migrate                             \033[0m  Casts migrations:migrate witiout xdebug in app container.\n\
\033[0mmake migration                           \033[0m  Casts make:migration witiout xdebug in app container.\n\
\n\
\033[0m\033[0;32m[Testing]\033[0m\n\
\n\
Please, aware that you running in DEV mode \n\
\n\
\033[0mmake logs                                \033[0m  Casts docker-compose logs -f.\n\
\n\
\033[0mmake <container_name> <commands_chain>   \033[0m  Casts docker exec -it <container_name> <commands_chain>. Example: make app bash - enter in ${PROJECT_PREFIX}-app container with bash.\n\
"

composer-install:
	if [ -a composer.lock ] ; \
    then \
         rm composer.lock ; \
    fi;
	@cd $(DOCKER_DIR) ; \
	$(EXEC) php-fpm bash -c "composer install --optimize-autoloader"

i:
	@make composer-install

up:
	@echo "\033[0m-------------------------------------- Starting \033[0;32mdev\033[0m environment ------ \033[0m\n"
	@make down
	@make volumes
	@cd $(DOCKER_DIR) && \
	$(SERVICES) up -d --build


start:
	@echo "\033[0m-------------------------------------- Starting \033[0;32mdev\033[0m environment ------ \033[0m\n"
	@make down
	@make volumes
	@cd $(DOCKER_DIR) && \
	$(SERVICES) up --build

down:
	@cd $(DOCKER_DIR) && \
	$(SERVICES) down

volumes:
	@$(BIN_DOCKER) volume create --name=app-sync
	@$(BIN_DOCKER) volume create --name=data-sync
	@$(BIN_DOCKER) volume create --name=php-fpm-logs-sync
	@$(BIN_DOCKER) volume create --name=php-fpm-conf-sync
	@$(BIN_DOCKER) volume create --name=php-fpm-web-sync

build:
	cd $(DOCKER_DIR) && if [ ! -f .env ]; then cp .env.dist .env; fi && \
	$(SERVICES) pull ; \
	$(SERVICES) build ; \
	cd .. ; \
	make up && \
	make composer-install && \
	make migrate ENV=$(ENV)

rebuild: down drop build

drop:
	@ rm -rf $(DOCKER_DIR)/mysql/data && mkdir $(DOCKER_DIR)/mysql/data ;  \
	echo -n > $(DOCKER_DIR)/nginx/logs/access.log ; \
	echo -n > $(DOCKER_DIR)/nginx/logs/api.content.access.log ; \
	echo -n > $(DOCKER_DIR)/nginx/logs/cdb.content.access.log ; \
	echo -n > $(DOCKER_DIR)/nginx/logs/error.log ; \
	echo -n > $(DOCKER_DIR)/nginx/logs/api.content.error.log ; \
	echo -n > $(DOCKER_DIR)/nginx/logs/cdb.content.error.log ; \
	echo -n > $(DOCKER_DIR)/php-fpm/logs/web.log ; \
	echo -n > $(DOCKER_DIR)/webdav/logs/access.log ; \
	echo -n > $(DOCKER_DIR)/webdav/logs/error.log

%:
	@cd $(DOCKER_DIR)
	@$(BIN_DOCKER) exec -it $(PREFIX)-$(firstword $(MAKECMDGOALS)) $(subst $(firstword $(MAKECMDGOALS)),, $(MAKECMDGOALS))