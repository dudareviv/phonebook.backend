#!make
include environments/docker/.env
include app/.env

ENV					   ?= dev
PREFIX		 			= ${PROJECT_PREFIX}

DOCKER_DIR              = environments/docker
BIN_DOCKER 			    = docker
BIN_DOCKER_COMPOSE 	    = docker-compose
DOCKER_COMPOSE_FILES    = -f docker-compose.yml
SERVICES 				= $(BIN_DOCKER_COMPOSE) $(DOCKER_COMPOSE_FILES)
EXEC                    = $(SERVICES) exec


help:
	@echo "Project management tool. Please, make sure you have .env file.\n"
	@echo "Usage: \n\
\n\
\033[0m\033[0;32m[Running]\033[0m\n\
\n\
\033[0mmake up                                  \033[0m  Casts docker-compose up -d --build.\n\
\033[0mmake start                               \033[0m  Casts docker-compose up --build.\n\
\033[0mmake down                                \033[0m  Casts docker-compose down.\n\
\n\
\033[0mmake <container_name> <commands_chain>   \033[0m  Casts docker exec -it <container_name> <commands_chain>. Example: make app bash - enter in ${PROJECT_PREFIX}-app container with bash.\n\
"

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


migrate:
	@echo "\033[0m---------------------- Run migrations in $(ENV) environment ---------------------- \033[0m\n" && \
	cd $(DOCKER_DIR) && \
	$(EXEC) app bash -c "php -d memory_limit=1G bin/console -vvv --env=$(ENV) doctrine:migrations:migrate --no-interaction" && \
	cd ../..


admins:
	@echo "\033[0m---------------------- Make admins in $(ENV) environment ---------------------- \033[0m\n" && \
	cd $(DOCKER_DIR) && \
	$(EXEC) app bash -c "php -d memory_limit=1G bin/console -vvv --env=$(ENV) fos:user:create admin admin@example.com password" && \
	$(EXEC) app bash -c "php -d memory_limit=1G bin/console -vvv --env=$(ENV) fos:user:promote admin ROLE_ADMIN" && \
	cd ../..


rebuild-databases:
	@make rebuild-database ENV=dev && \
	 make rebuild-database ENV=test


rebuild-database:
	@echo "\033[0m---------------------- Recreate database in $(ENV) environment ---------------------- \033[0m\n" && \
	cd $(DOCKER_DIR) && \
	$(EXEC) app bash -c "php -d memory_limit=1G bin/console -vvv --env=$(ENV) doctrine:database:drop --force" && \
	$(EXEC) app bash -c "php -d memory_limit=1G bin/console -vvv --env=$(ENV) doctrine:database:create" && \
	cd ../.. && \
	make migrate ENV=$(ENV) && \
	make admins ENV=$(ENV)

keys:
	cd $(DOCKER_DIR) && \
	$(EXEC) app bash -c "openssl genpkey -out config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -pass pass:$(JWT_PASSPHRASE)" && \
	$(EXEC) app bash -c "openssl pkey -in config/jwt/private.pem -out config/jwt/public.pem -pubout -passin pass:$(JWT_PASSPHRASE)" && \
	cd ../..

%:
	@cd $(DOCKER_DIR)
	@$(BIN_DOCKER) exec -it $(PREFIX)-$(firstword $(MAKECMDGOALS)) $(subst $(firstword $(MAKECMDGOALS)),, $(MAKECMDGOALS))