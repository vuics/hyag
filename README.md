# HyperAgency (HyAg)

[HyperAgency](https://hyag.org/) is an agentic AI platform. It is open-source and distributed. The platfrom can be used as a framework to build autonomous software companies.

HyperAgency allows:
* Create, manage, deploy agents.
* Communicate to agents and humans.
* Assemble, orchestrate and coordinate smart AI-human teams.
* Visual coordination interface (Map) to quickly get started and iterate.
* Source code access lets you customize any component using JavaScript, Node.js and Python.
* Interactive playground to immediately test and refine your flows with step-by-step control.
* Multi-agent orchestration with conversation management.
* Deploy as an API or export/import as JSON.
* Distributed (Nodes of HyperAgency can be connected to other nodes).
* Enterprise-ready security and scalability.

Learn more in [Docs](https://docs.hyag.org/).

## Prerequisites

Install the services on your system:
* [Docker](https://www.docker.com/).

## Setup

You can set up the system to run it locally.

### Init Submodules

The repo consists of submodules. Clone them with:

```bash
git submodule update --init --recursive
```

### Setup Local DNS

```bash
export $(xargs < .env) && \
sudo tee -a /etc/hosts << EOF

# Hyper-Agency
# db, messaging, models, dependencies
127.0.0.1 ${DOMAIN}
127.0.0.1 mongo.${DOMAIN}
127.0.0.1 redis.${DOMAIN}
127.0.0.1 vault.${DOMAIN}
127.0.0.1 postgres.${DOMAIN}
127.0.0.1 chroma.${DOMAIN}
127.0.0.1 selfdev-prosody.${DOMAIN}
127.0.0.1 conference.selfdev-prosody.${DOMAIN}
127.0.0.1 share.selfdev-prosody.${DOMAIN}
127.0.0.1 ollama.${DOMAIN}
127.0.0.1 selfdev-speech.${DOMAIN}
127.0.0.1 selfdev-avatar.${DOMAIN}
# main
127.0.0.1 selfdev-api.${DOMAIN}
127.0.0.1 selfdev-web.${DOMAIN}
# docs
127.0.0.1 docs.${DOMAIN}

EOF
```

#### Setup DNS for S2S (Optionally)

Setup DNS on both machines for server-2-server communication:

On `dev.local` machine:
```bash
export $(xargs < .env) && \
export IP=$(ping -c 1 ${REMOTE_DOMAIN} | awk -F '[()]' '/PING/ { print $2 }') && \
sudo tee -a /etc/hosts << EOF

# For server-to-server comminucation to another HyperArgency & Prosody XMMP
${IP} ${REMOTE_DOMAIN}
${IP} selfdev-api.${REMOTE_DOMAIN}
${IP} selfdev-web.${REMOTE_DOMAIN}
${IP} conference.${REMOTE_DOMAIN}
${IP} selfdev-prosody.${REMOTE_DOMAIN}
${IP} conference.selfdev-prosody.${REMOTE_DOMAIN}

EOF
```

### Configure Env Vars

Create [./env](./.env) file with `DOMAIN` and `REMOTE_DOMAIN` (optional) env vars. You can see [env.example](./env.example) as an example. There are also examples of those .env files in [./selfdev-api/env.example](./selfdev-api/env.example) and [./selfdev-agency/env.example](./selfdev-agency/env.example). 

You can copy these .env files from the templates:
```bash
cp env.example .env
cp selfdev-api/env.example selfdev-api/.env
cp selfdev-agency/env.example selfdev-agency/.env
```

Edit the .env files to configure your instance and services correctly. You also need to set the keys as environment variables in the files below:

- .env
- ./selfdev-api/.env
- ./selfdev-agency/.env

### Generate Certificates

Generate certificates for local development:

```bash
./gen-certs.sh
```

After you generated certificates, add them on Keychain Access tool by clicking on the certificate files in the [./certs/](./certs/) directory. It is a standard system tool on MacOS.

### Run the Tech Stack

Run the whole stack using docker-compose with profiles:

```bash
docker-compose up
```

Profiles:
• `main` - web app, backend API server.
• `prosody` - XMPP messaging backend.
• `agents` runs agents.
• `docs` runs containers that show documents.
• `postgres` runs PostgreSQL.
• `ollama` runs Ollama.
• `chroma` runs Chroma.
• `vault` runs Vault.

Some profiles may inlcude services from other profiles.

See the full list of `profiles` in the [./docker-compose.yml](./docker-compose.yml).

### Initialize Vault

After you started the stack in docker-compose, you need to initialize the vault.

```bash
export VAULT_ADDR='http://127.0.0.1:8200'

vault operator init -key-shares=5 -key-threshold=3

# Output of `vault operator init -key-shares=1 -key-threshold=1` command:
#
# Unseal Key 1: <key1>
# Unseal Key 2: <key2>
# Unseal Key 3: <key3>
# Unseal Key 4: <key4>
# Unseal Key 5: <key5>
#
# Initial Root Token: <root-token>

# Run it 3 times with 3 unsealed tokens
vault operator unseal
# <key1>
vault operator unseal
# <key2>
vault operator unseal
# <key3>

# Check that the Sealed: false
vault status

# Replace with your actual token
export VAULT_TOKEN='<root-token>'

vault login $VAULT_TOKEN

vault secrets list -detailed
# if no secret/ path, input:
vault secrets enable -path=secret kv-v2
```

Update `VAULT_TOKEN` and `VAULT_UNSEAL_KEYS` values in `.env` files:
- ./selfdev-api/.env
- ./selfdev-agency/.env

Restart the stack with `docker compose`.

### Open

Below, replace `dev.local` with your `${DOMAIN}`.

Open the following URLs in the browser:

* [Selfdev-web app](http://selfdev-web.dev.local:3690/)

Depending on the settings, you may need to open the same apps through HTTPS:

* [Open selfdev-web app through HTTPS](https://selfdev-web.dev.local:3690/)
* [Open selfdev-api once to allow using insecure self-signed certificate](https://selfdev-api.dev.local:6369)
* [Open selfdev-prosody once to allow using insecure self-signed certificate](https://selfdev-prosody.dev.local:5281/conversejs/)

### Stop

```bash
docker-compose down
```

## Acknoledgements

I acknoledge the ideological contribution, influcence and feedback given by Hal Casteel and William McKinley. Big thanks for the inspiration.
