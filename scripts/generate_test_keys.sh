#!/bin/sh
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e


echo "Generating trustbloc-did-method Test PKI"

cd /opt/workspace/trustbloc-did-method
mkdir -p test/bdd/fixtures/keys/tls
tmp=$(mktemp)
echo "subjectKeyIdentifier=hash
authorityKeyIdentifier = keyid,issuer
extendedKeyUsage = serverAuth
keyUsage = Digital Signature, Key Encipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = testnet.trustbloc.local
DNS.3 = stakeholder.one
DNS.4 = stakeholder.two
DNS.5 = sidetree-mock" >> "$tmp"

#create CA
openssl ecparam -name prime256v1 -genkey -noout -out test/bdd/fixtures/keys/tls/ec-cakey.pem
openssl req -new -x509 -key test/bdd/fixtures/keys/tls/ec-cakey.pem -subj "/C=CA/ST=ON/O=Example Internet CA Inc.:CA Sec/OU=CA Sec" -out test/bdd/fixtures/keys/tls/ec-cacert.pem

#create TLS creds
openssl ecparam -name prime256v1 -genkey -noout -out test/bdd/fixtures/keys/tls/ec-key.pem
openssl req -new -key test/bdd/fixtures/keys/tls/ec-key.pem -subj "/C=CA/ST=ON/O=Example Inc.:trustbloc-did-method/OU=trustbloc-did-method/CN=localhost" -out test/bdd/fixtures/keys/tls/ec-key.csr
openssl x509 -req -in test/bdd/fixtures/keys/tls/ec-key.csr -CA test/bdd/fixtures/keys/tls/ec-cacert.pem -CAkey test/bdd/fixtures/keys/tls/ec-cakey.pem -CAcreateserial -extfile "$tmp" -out test/bdd/fixtures/keys/tls/ec-pubCert.pem -days 365

# generate key pair for recover/updates
mkdir -p test/bdd/fixtures/keys/recover
mkdir -p test/bdd/fixtures/keys/update
mkdir -p test/bdd/fixtures/keys/update2

openssl ecparam -name prime256v1 -genkey -noout -out test/bdd/fixtures/keys/recover/key.pem
openssl ec -in test/bdd/fixtures/keys/recover/key.pem -passout pass:123 -out test/bdd/fixtures/keys/recover/key_encrypted.pem -aes256
openssl ec -in test/bdd/fixtures/keys/recover/key.pem -pubout -out test/bdd/fixtures/keys/recover/public.pem
openssl ecparam -name prime256v1 -genkey -noout -out test/bdd/fixtures/keys/update/key.pem
openssl ec -in test/bdd/fixtures/keys/update/key.pem -passout pass:123 -out test/bdd/fixtures/keys/update/key_encrypted.pem -aes256
openssl ec -in test/bdd/fixtures/keys/update/key.pem -pubout -out test/bdd/fixtures/keys/update/public.pem
openssl ecparam -name prime256v1 -genkey -noout -out test/bdd/fixtures/keys/update2/key.pem
openssl ec -in test/bdd/fixtures/keys/update2/key.pem -passout pass:123 -out test/bdd/fixtures/keys/update2/key_encrypted.pem -aes256
openssl ec -in test/bdd/fixtures/keys/update2/key.pem -pubout -out test/bdd/fixtures/keys/update2/public.pem


echo "done generating trustbloc-did-method PKI"
