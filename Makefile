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

# Certbot ----------------------------------------------------------------------

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
								--email $(SSL_EMAIL) \
								--flush

# Demais Comandos --------------------------------------------------------------

up-test: down
	$(DOCKER_COMPOSE) up

up: down
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

restart: down up
