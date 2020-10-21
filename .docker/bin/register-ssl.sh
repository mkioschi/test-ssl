#!/bin/sh

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
	echo; echo "[Error] Execute o $0 como root."; echo;
	exit
fi

# Inicializa as variáveis
diretorio=.docker/server/letsencrypt
docker_compose=
dominios=
email=
staging=0
rsa_key_size=4096

# Popula as variáveis com as opções passadas na execução
while [ -n "$1" ]
do
    case "$1" in
        # Define o prefixo do docker-compose
        -dc | --docker-compose)
            docker_compose=("$2")
        shift
        ;;

        # Define os domínios
        -d | --dominios)
            dominios=("$2")
        shift
        ;;

        # Define o email
        -e | --email)
            email="$2"
        shift
        ;;

        # Define se é staging
        -s | --staging)
            staging=1
        shift
        ;;

        # Opções não mapeadas
        *)
            echo; echo "[Error] A opção $1 é desconhecida."; echo;
            exit 1
        ;;
    esac
    shift
done

# Valida variáveis obrigatórias
if [ -z "$docker_compose" ]; then
    echo; echo "[Error] O prefixo do docker-compose é obrigatório."; echo;
    exit 1
fi

if [ -z "$dominios" ]; then
    echo; echo "[Error] Ao menos um domínio é obrigatório."; echo;
    exit 1
fi

if [ -z "$email" ]; then
    echo; echo "[Error] O email é obrigatório."; echo;
    exit 1
fi

# Cria diretórios necessários, caso não existam (-p)
mkdir -p "$diretorio/nginx-options"

# Parâmetros TLS recomendados
options_ssl_nginx="$diretorio/nginx-options/options-ssl-nginx.conf"

if [ ! -e $options_ssl_nginx ]; then
	echo "[i] Baixando configurações SSL recomendadas...";
	curl -s "https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf" > $options_ssl_nginx
fi

# Parâmetros Diffie–Hellman
echo "[i] Criando certificado Diffie–Hellman...";
$docker_compose run --rm --entrypoint "openssl dhparam -out '/etc/letsencrypt/ssl-dhparams.pem' $rsa_key_size" certbot

# Certificados fake
for dominio in ${dominios[@]}; do
    diretorio_dominio="$diretorio/live/$dominio"

    mkdir -p $diretorio_dominio

    if [ ! -e "$diretorio_dominio/cert.pem" ]; then
        echo "[i] Criando certificado fake para o domínio $dominio...";

        path="/etc/letsencrypt/live/$dominio"

        $docker_compose run --rm --entrypoint "openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1 -keyout '$path/privkey.pem' -out '$path/fullchain.pem' -subj '/CN=localhost'" certbot

        cp -p "$diretorio_dominio/fullchain.pem" "$diretorio_dominio/chain.pem"
    fi
done

# Reinicia o serviço do Nginx (server)
echo "[i] Reiniciando nginx...";

$docker_compose up -d server && $docker_compose restart server