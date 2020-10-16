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

## Instalação do certificado SSL:

Para instalar o certificado SSL é necessário a variável de ambiente `ENV=prod` estar definida.

#### 1. Desligue todos serviços do Docker:

```console
$ make down
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

## Comandos Make disponíveis

Lista todos comandos Make disponíveis na aplicação:

```console
$ make help
```
