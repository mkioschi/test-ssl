# Verifica se o arquivo .env existe no projeto. Caso não exista, mata a execução do script.
ENV_FILE=./.env
ifeq ("$(wildcard $(ENV_FILE))","")
$(error Arquivo .env não encontrado.)
endif

# Exporta todas variáveis do arquivo .env para variáveis de ambiente em tempo
# de execução, ou seja, somente durante o uso do script.
include .env
export

# Certbot ----------------------------------------------------------------------

register-ssl-staging:
	@chmod +x .docker/bin/register-ssl.sh
	@sudo .docker/bin/register-ssl.sh \
								--dominios "$(SSL_DOMINIOS)" \
								--email $(SSL_EMAIL) \
								--staging

register-ssl:
	@chmod +x .docker/bin/register-ssl.sh
	@sudo .docker/bin/register-ssl.sh \
								--dominios "$(SSL_DOMINIOS)" \
								--email $(SSL_EMAIL) \
								--flush

# Demais Comandos --------------------------------------------------------------

start-test: 
	docker-compose up

start: 
	docker-compose up -d

stop:
	docker-compose down

restart: stop start
