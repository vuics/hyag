#!/bin/sh

# Import .env
set -a
source .env
set +a

# Install
brew install mkcert
mkcert -install

# Make sure DOMAIN is set
if [ -z "$DOMAIN" ]; then
  echo "DOMAIN is not set. Please export DOMAIN=yourdomain.com"
  exit 1
fi

generate_cert() {
  local dir="./certs/$1"
  local host="$1"

  if [ ! -d "$dir" ]; then
    echo "Creating directory: $dir"
    mkdir -p "$dir"
    echo "Generating certificate for $host"
    mkcert -key-file "$dir/tls.key" -cert-file "$dir/tls.crt" "$host"
  else
    echo "Directory already exists: $dir — skipping"
  fi
}

# List of hostnames to generate certificates for
generate_cert "${DOMAIN}"
generate_cert "localhost"
generate_cert "selfdev-web.${DOMAIN}"
generate_cert "selfdev-api.${DOMAIN}"
generate_cert "selfdev-prosody.${DOMAIN}"
generate_cert "conference.selfdev-prosody.${DOMAIN}"
generate_cert "share.selfdev-prosody.${DOMAIN}"
