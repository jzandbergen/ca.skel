#!/bin/bash

set -ex

# Create Root CA private key
# NOTE: needs user input
openssl genrsa -aes256 -out private/ca.key.pem 4096

chmod 400 private/ca.key.pem

# Create Root CA Self Signed Cert
# NOTE: needs user input
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem

chmod 444 certs/ca.cert.pem

# Create Intermediate CA private key
# NOTE: needs user input
openssl genrsa -aes256 \
      -out intermediate/private/intermediate.key.pem 4096

chmod 400 intermediate/private/intermediate.key.pem

# Create Intermediate CA Certficate Signing Request(CSR)
# NOTE: needs user input
openssl req -config intermediate/openssl.cnf -new -sha256 \
      -key intermediate/private/intermediate.key.pem \
      -out intermediate/csr/intermediate.csr.pem

# Create Intermediate CA Certificate signed by Root CA
# from the CSR.
# NOTE: needs user input
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem

# Create the certificate bundle
cat intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
