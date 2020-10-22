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
								--email $(SSL_EMAIL)

generate-certbot-test: up-server restart-server
	$(DOCKER_COMPOSE) run --rm --entrypoint "certbot certonly --webroot -w /var/www/public -d $(DOMAIN) --email $(EMAIL) --agree-tos --no-eff-email --force-renewal --staging --non-interactive" certbot

generate-certbot: up-server restart-server
	$(DOCKER_COMPOSE) run --rm --entrypoint "certbot certonly --webroot -w /var/www/public -d $(DOMAIN) --email $(EMAIL) --agree-tos --no-eff-email --force-renewal --non-interactive" certbot

# Demais Comandos --------------------------------------------------------------

up-test: down
	$(DOCKER_COMPOSE) up --build --force-recreate

up: down
	$(DOCKER_COMPOSE) up -d --build --force-recreate

down:
	$(DOCKER_COMPOSE) down

restart: down up
