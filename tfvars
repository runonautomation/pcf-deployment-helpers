env_name         = "pcf"
project          = "${PROJECT_ID}"
region           = "${REGION}"
zones            = ["${REGION}-a", "${REGION}-b", "${REGION}-c"]
dns_suffix       = "${DOMAIN}"
opsman_image_url = "https://storage.googleapis.com/ops-manager-us/pcf-gcp-2.2-build.305.tar.gz"
pks              = true
external_database = true

buckets_location = "US"

ssl_ca_cert = <<SSL_CA
${SSLCA}
SSL_CA

ssl_ca_private_key = <<SSL_CAK
${SSLCAK}
SSL_CAK

service_account_key = <<SERVICE_ACCOUNT_KEY
${SK}
SERVICE_ACCOUNT_KEY
