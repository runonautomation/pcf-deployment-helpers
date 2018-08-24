export DOMAIN=${DOMAIN:-example.com}
export TERRAFORM_SOLUTION_PATH=${TERRAFORM_SOLUTION_PATH:-~/terraforming-gcp}
export SSLCA=$(cat gen/root-ca/certs/ca.crt)
export SSLCAK=$(cat gen/root-ca/private/ca.key)
export PROJECT_ID=$(cat deploy.key.json  | grep project_id | awk -F\" '{print $4}')
export REGION=us-central1
export SK=$(cat deploy.key.json)

envsubst < "tfvars" > "$TERRAFORM_SOLUTION_PATH/terraform.tfvars"
cat $TERRAFORM_SOLUTION_PATH/terraform.tfvars