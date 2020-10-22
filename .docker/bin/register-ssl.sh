#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
	echo; echo "[error] Execute o $0 como root."; echo;
	exit
fi

# TODO Verificar versão do docker-compose para 

# Inicializa as variáveis
diretorio=.docker/server/letsencrypt
docker_compose=
dominios=
email=
staging=0
rsa_key_size=4096
staging_arg=
dominios_args=

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
            echo; echo "[error] A opção $1 é desconhecida."; echo;
            exit 1
        ;;
    esac
    shift
done

# Valida variáveis obrigatórias
if [ -z "$docker_compose" ]; then
    echo; echo "[error] O prefixo do docker-compose é obrigatório."; echo;
    exit 1
fi

if [ -z "$dominios" ]; then
    echo; echo "[error] Ao menos um domínio é obrigatório."; echo;
    exit 1
fi

if [ -z "$email" ]; then
    echo; echo "[error] O email é obrigatório."; echo;
    exit 1
fi

# Parâmetros Diffie–Hellman
echo; echo "[i] Criando certificado Diffie–Hellman..."; echo;

$docker_compose run --rm --entrypoint "openssl dhparam -out '/etc/letsencrypt/ssl-dhparams.pem' $rsa_key_size" certbot

# Cria certificados fake
for dominio in ${dominios[@]}; do
    diretorio_dominio="$diretorio/live/$dominio"

    mkdir -p $diretorio_dominio

    if [ ! -e "$diretorio_dominio/cert.pem" ]; then
        echo; echo "[i] Criando certificado fake para o domínio $dominio..."; echo;

        path="/etc/letsencrypt/live/$dominio"

        $docker_compose run --rm --entrypoint "openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1 -keyout '$path/privkey.pem' -out '$path/fullchain.pem' -subj '/CN=localhost'" certbot

        cp -p "$diretorio_dominio/fullchain.pem" "$diretorio_dominio/chain.pem"
    fi
done

# Reinicia o serviço do Nginx (server)
echo; echo "[i] Reiniciando nginx..."; echo;

$docker_compose up -d server && $docker_compose restart server

# Gera certificados ------------------------------------------------------------

# Habilita o modo staging
if [ $staging = 1 ]; then staging_arg="--staging"; fi

# Monta argumentos dos domínios
for dominio in ${dominios[@]}; do
    diretorio_dominio="$diretorio/live/$dominio"

    if [ -e "$diretorio_dominio/cert.pem" ]; then
        echo; echo "[i] O certificado do domínio $dominio já existe."; echo;
    else
        echo; echo "[i] Apagando certificado fake do domínio $dominio..."; echo;

        # Remove diretório do certificado fake
        rm -rf $diretorio_dominio

        # Adiciona o domínio nos args de criação de certificado
    	dominios_args="$dominios_args -d $dominio"
    fi
done

echo; echo "[i] Criando certificados."; echo;

$docker_compose run --rm --entrypoint "certbot certonly --webroot -w /var/www/certbot $dominios_args $staging_arg --email $email --rsa-key-size $rsa_key_size --agree-tos --no-eff-email --force-renewal" certbot
