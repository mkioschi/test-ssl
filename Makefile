# Verifica se o arquivo .env existe no projeto. Caso não exista, mata a execução do script.
ENV_FILE=./.env
ifeq ("$(wildcard $(ENV_FILE))","")
$(error Arquivo .env não encontrado.)
endif

# Exporta todas variáveis do arquivo .env para variáveis de ambiente em tempo de execução, ou seja, somente durante o uso do script.
include .env
export

# Verifica qual ambiente está setado no arquivo .env.
ifeq ($(ENV), dev)
DOCKER_COMPOSE=docker-compose -f docker-compose.dev.yml
else ifeq ($(ENV), test)
DOCKER_COMPOSE=docker-compose -f docker-compose.test.yml
else ifeq ($(ENV), prod)
DOCKER_COMPOSE=docker-compose -f docker-compose.prod.yml
else
$(error Variável "ENV" não definida no arquivo .env ou inválida.)
endif

# ------------------------------------------------------------------------------
# Comandos Make
# ------------------------------------------------------------------------------

# Certbot --------------------------------------------------------------

register-ssl-staging:
	@chmod +x .docker/bin/register-ssl.sh
	@sudo .docker/bin/register-ssl.sh \
									--docker-compose "$(DOCKER_COMPOSE)" \
									--dominios "$(SSL_DOMINIOS)" \
									--email $(SSL_EMAIL) \
									--staging

register-ssl:
	@chmod +x .docker/bin/register-ssl.sh
	@sudo .docker/bin/register-ssl.sh \
									--docker-compose "$(DOCKER_COMPOSE)" \
									--dominios "$(SSL_DOMINIOS)" \
									--email $(SSL_EMAIL)

generate-certbot-test: up-server restart-server
	$(DOCKER_COMPOSE) run --rm --entrypoint "certbot certonly --webroot -w /var/www/public -d $(DOMAIN) --email $(EMAIL) --agree-tos --no-eff-email --force-renewal --staging --non-interactive" certbot

generate-certbot: up-server restart-server
	$(DOCKER_COMPOSE) run --rm --entrypoint "certbot certonly --webroot -w /var/www/public -d $(DOMAIN) --email $(EMAIL) --agree-tos --no-eff-email --force-renewal --non-interactive" certbot

# Serviço server -------------------------------------------------------

bash-server:
	$(DOCKER_COMPOSE) exec server bash

up-server:
	$(DOCKER_COMPOSE) up -d server

restart-server:
	$(DOCKER_COMPOSE) restart server

# Comandos globais/Docker  -----------------------------------------------------

config:
	$(DOCKER_COMPOSE) config

up-test: down
	$(DOCKER_COMPOSE) up --build --force-recreate

up: down
	$(DOCKER_COMPOSE) up -d --build --force-recreate

down:
	$(DOCKER_COMPOSE) down

restart: down up

install:

help:
	@echo ""
	@echo "Utilização: 'make <comando>'. Comandos disponíveis:"
	@echo ""
	@echo "  Comandos para todos os serviços:"
	@echo "    config                   Exibir variáveis e configuração do Docker."
	@echo "    build                    Executa o build em todos serviços."
	@echo "    up                       Roda todos serviços."
	@echo "    down                     Para todos serviços."
	@echo "    restart                  Reinicia todos serviços."
	@echo "    recreate                 Executa o build nos serviços apagando os dados dos volumes."
	@echo "    build                    Executa o build de todos serviços."
	@echo "    install                  Instala as dependencias de todos Dependency Managers da aplicação."
	@echo ""
	@echo "  Comandos para o serviço 'server':"
	@echo "    bash-server              Entra no bash do serviço 'server'."
	@echo ""
