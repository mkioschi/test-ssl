# PHP7 + Nginx + Certbot

## Instalação

Clone o projeto e entre em seu diretório.

## Configuração inicial

#### 1. Criação do arquivo .env baseado no exemplo:

```console
$ cp .env.example .env
```

#### 2. Criação do arquivo de host:

Caso esteja no ambiente de desenvolvimento, copie o arquivo `localhost.conf` para a pasta `sites-enable`. Caso esteja em produção, copie o arquivo `example.com.conf`.

```console
$ cp .docker/server/sites-available/example.com.conf .docker/server/sites-enabled/
```

#### 3. Inicialização dos serviços do Docker:

```console
$ make up
```

#### 4. Configuração dos Hosts:

Adicione o registro abaixo no arquivo `/etc/hosts`.

```console
127.0.0.1   example.local
```

## Instalação do certificado SSL

Para instalar o certificado SSL é necessário a variável de ambiente `ENV=prod` estar definida.

#### 1. Reinicie todos serviços do Docker:

_É de extrema importância rodar o comando `make up` com a variável `ENV=prod` e o arquivo de host sem SSL na pasta `sites-enabled`. Pois a geração do certificado pelo Let's Encrypt exige um teste com o domínio sem o redirect para HTTPS._

```console
$ make down && make up
```

#### 2. Arquivo de host com o SSL:

Remova o arquivo sem SSL:

```console
$ rm .docker/server/sites-enabled/example.com.conf
```

E substitua pelo arquivo com os certificados SSL (`.ssl.conf`).

```console
$ cp .docker/server/sites-available/example.com.ssl.conf .docker/server/sites-enabled/
```

Por fim, reinicie os serviços novamente:

```console
$ make down && make up
```

## Renovar Certificados

#### 1. Torne o arquivo `ssl_renew.sh` executável:

```console
$ chmod +x ssl_renew.sh
```

#### 2. Adicione a execução intermitente desse arquivo no crontab:

```console
0 12 * * * /var/www/meu_projeto/.docker/ssl/bin/ssl_renew.sh >> /var/log/cron.log 2>&1
```

## Comandos Make disponíveis

Lista todos comandos Make disponíveis na aplicação:

```console
$ make help
```

## Fontes:

- https://www.digitalocean.com/community/tutorials/how-to-secure-a-containerized-node-js-application-with-nginx-let-s-encrypt-and-docker-compose-pt#passo-6-%E2%80%94-renovando-certificados
