set -e
export DOMAIN=${DOMAIN:-glpractices.com}
export TERRAFORM_SOLUTION_PATH=${TERRAFORM_SOLUTION_PATH:-./pcfcerts}
export KEY_LOCATION=${KEY_LOCATION:-~/deploy.key.json}

export SSLCA=$(cat gen/root-ca/certs/ca.crt)
export SSLCAK=$(cat gen/root-ca/private/ca.key)

export PROJECT_ID=$(cat $KEY_LOCATION   | grep project_id | awk -F\" '{print $4}')
export REGION=us-central1
export SK=$(cat $KEY_LOCATION )

envsubst < "tfvars" > "$TERRAFORM_SOLUTION_PATH/terraform.tfvars"
cat makecerts/terraform.tfvars