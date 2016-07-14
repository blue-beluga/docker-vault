
# [<img src=".bluebeluga.png" height="100" width="200" style="border-radius: 50%;" alt="@fancyremarker" />](https://github.com/blue-beluga/docker-vault) bluebeluga/vault

Alpine Linux image with [Vault](http://vaultproject.io).

Vault uses TCP/8200 by default, so we'll keep that. The demo configuration is listening on all interfaces (not just localhost), and using demo.consul.io as per the [getting started docs](https://vaultproject.io/intro/getting-started/deploy.html).

Configuration is stored under `config/`.

    $ docker pull bluebeluga/vault

## Usage

```bash
#!/bin/bash

# Path to vault config file.
MY_VAULT_CONFIG=/path/to/vault.hcl

# If you're using docker-machine, change this to the IP of your docker host.
DOCKER_HOST=127.0.0.1

# Access to the vault server via local CLI.
export VAULT_ADDR=http://$DOCKER_HOST:8200

docker run \
	--rm \
	--name vault-dev \
	--memory-swap -1 \
	-v "$MY_VAULT_CONFIG:/etc/vault.hcl" \
	-p 8200:8200 \
	bluebeluga/vault

```

## Vault Server

### Dev mode

Start by default in **dev mode**:

    $ docker run -it \
      -p 8200:8200 \
      --hostname vault \
      --name vault bluebeluga/vault

(note that if you're in **dev mode** using docker-machine or similar, the `vault` daemon will listen only on 127.0.0.1 ; it won't be available directly from your workstation)

### Using the Demo Consul Backend

Start with a **demo Consul backend** using [demo.consul.io](https://demo.consul.io):

    $ docker run -it \
      -p 8200:8200 \
      --hostname vault \
      --name vault \
      --volume $PWD/config:/config \
      bluebeluga/vault server -config=/config/demo.hcl

### Using your own Consul backend

If you have a running Consul container named `consul`, you can just use it:

    $ docker run -it \
      -p 8200:8200 \
      --hostname vault \
      --name vault \
      --link consul:consul \
      --volume $PWD/config:/config \
      bluebeluga/vault server -config=/config/consul.hcl

## Using Vault

To initialize Vault, on your workstation with `vault` installed (remember, in _dev mode_ it won't work as the daemon listens only on 127.0.0.1, see below for more):

    $ export VAULT_ADDR='http://a.b.c.d:8200'
    $ vault init

### Using docker-machine

If you happen to run docker from inside a VM (ie.: docker-machine with VirtualBox or VMware etc.), you can still use the **dev mode** by launching a shell from inside the container:

```
$ docker exec -t -i vault /bin/sh
# vault version
Vault v0.4.1
# vault --help
[...]
```

Then [RTFM](https://vaultproject.io/intro/getting-started/first-secret.html) for Vault usage.

## Consul

I'm using [Progrium's Consul Docker box](https://github.com/gliderlabs/docker-consul), it's working great.
Here's with the WebUI:

    $ docker run -p 8400:8400 -p 8500:8500 -p 8600:53/udp --hostname consul --name consul progrium/consul -server -bootstrap -ui-dir /ui

The [WebGUI](http://a.b.c.d:8500/) should be available.

## Vault Client

You can use it as a `vault` client too:

    $ alias vault="docker run --rm -e "VAULT_ADDR=$VAULT_ADDR" bluebeluga/vault"
    $ vault version
