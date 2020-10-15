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
DOCKER_COMPOSE_PREFIX=docker-compose -f docker-compose.dev.yml
else ifeq ($(ENV), test)
DOCKER_COMPOSE_PREFIX=docker-compose -f docker-compose.test.yml
else ifeq ($(ENV), prod)
DOCKER_COMPOSE_PREFIX=docker-compose -f docker-compose.prod.yml
else
$(error Variável "ENV" não definida no arquivo .env ou inválida.)
endif

# "docker-compose exec" do serviço 'ofertei_server'
SERVER_EXEC_PREFIX=$(DOCKER_COMPOSE_PREFIX) exec ofertei_server bash -c

# ------------------------------------------------------------------------------
# Comandos Make
# ------------------------------------------------------------------------------

# Serviço ofertei_server -------------------------------------------------------

bash-server:
	$(DOCKER_COMPOSE_PREFIX) exec ofertei_server bash

up-server:
	$(DOCKER_COMPOSE_PREFIX) up -d ofertei_server 

restart-server:
	$(DOCKER_COMPOSE_PREFIX) restart ofertei_server 

# Comandos globais/Docker  -----------------------------------------------------

config:
	$(DOCKER_COMPOSE_PREFIX) config

build:
	$(DOCKER_COMPOSE_PREFIX) build

up:
	$(DOCKER_COMPOSE_PREFIX) up -d

down:
	$(DOCKER_COMPOSE_PREFIX) down

down-v:
	$(DOCKER_COMPOSE_PREFIX) down -v

restart: down up ps

recreate: down-v build up

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
	@echo "    down-v                   Para todos serviços limpando dados do volume."
	@echo "    restart                  Reinicia todos serviços."
	@echo "    recreate                 Executa o build nos serviços apagando os dados dos volumes."
	@echo "    build                    Executa o build de todos serviços."
	@echo "    install                  Instala as dependencias de todos Dependency Managers da aplicação."
	@echo ""
	@echo "  Comandos para o serviço 'ofertei_server':"
	@echo "    bash-server              Entra no bash do serviço 'ofertei_server'."
	@echo "    restart-server           Reinicia o serviço 'ofertei_server'."
	@echo ""
