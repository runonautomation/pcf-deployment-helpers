#!/bin/bash -x

set -e
mkdir -p gen 

export DOMAIN=${DOMAIN:-example.com}

rm gen/root-ca/index.txt* gen/root-ca/newcerts/ -rf

for C in `echo root-ca`; do
  mkdir -p gen/$C
  cd gen/$C
  mkdir -p certs crl newcerts private
  sleep 1
  cd ../..
  touch gen/$C/serial
  echo 1000 > gen/$C/serial
  touch gen/$C/index.txt gen/$C/index.txt.attr

  echo '
[ ca ]
default_ca = CA_default
[ CA_default ]
dir            = 'gen/$C'    # Where everything is kept
certs          = $dir/certs                # Where the issued certs are kept
crl_dir        = $dir/crl                # Where the issued crl are kept
database       = $dir/index.txt            # database index file.
new_certs_dir  = $dir/newcerts            # default place for new certs.
certificate    = $dir/cacert.pem                # The CA certificate
serial         = $dir/serial                # The current serial number
crl            = $dir/crl.pem                # The current CRL
private_key    = $dir/private/ca.key.pem       # The private key
RANDFILE       = $dir/.rnd     # private random number file
nameopt        = default_ca
certopt        = default_ca
policy         = policy_match
default_days   = 365
default_md     = sha256

[ policy_match ]
countryName            = optional
stateOrProvinceName    = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[v3_req]
basicConstraints = CA:TRUE
' > gen/$C/openssl.conf
done

openssl genrsa -out gen/root-ca/private/ca.key 2048
openssl req -config gen/root-ca/openssl.conf -new -x509 -days 3650 -key gen/root-ca/private/ca.key -sha256 -extensions v3_req -out gen/root-ca/certs/ca.crt -subj '/CN=PracticesCA'
