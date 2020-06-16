#!/bin/bash

set -xe

TEMPNAME=$(date "+%Y%m%d_%H:%M:%S")

openssl genrsa -aes256 \
      -out intermediate/private/${TEMPNAME}.key.pem 2048

chmod 400 intermediate/private/${TEMPNAME}.key.pem

openssl req -config intermediate/openssl.cnf \
      -key intermediate/private/${TEMPNAME}.key.pem \
      -new -sha256 -out intermediate/csr/${TEMPNAME}.csr.pem

NAME=$(openssl req -in intermediate/csr/${TEMPNAME}.csr.pem  -noout -subject | grep -Eo "CN=(.+)" |cut -c 4-)

mv intermediate/private/${TEMPNAME}.key.pem intermediate/private/${NAME}.key.pem
mv intermediate/csr/${TEMPNAME}.csr.pem intermediate/csr/${NAME}.csr.pem
unset TEMPNAME

openssl ca -config intermediate/openssl.cnf \
      -extensions usr_cert -days 375 -notext -md sha256 \
      -in intermediate/csr/${NAME}.csr.pem \
      -out intermediate/certs/${NAME}.cert.pem
