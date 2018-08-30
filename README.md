## Deployment playbook and documentation links
During the evaluation DevOps practice tried the available ways to deploy PCF on Google Cloud Platform, and came to conclusion that recommended approach is to use GCP terraform scripts to deploy the platform. 
Below you can find an action reference playbook for start the platform installation from scratch on your account.


### DNS
Register a DNS zone for your deployment.
Example dns zone: glpractices.com
You can expect that PCF services will be registered as:
pcf.pcf.glpractices.com (Ops Manager)

### GCP
Create a deployment host in a separate network that will have the deployment prerequisites installed.
Please refer to: https://docs.pivotal.io/pivotalcf/2-0/customizing/gcp-prepare-env-terraform.html
#### Prepare service account key for deployment
```
PROJECT_ID_DYNAMIC=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
PROJECT_ID=${GCP_PROJECT_ID:-$PROJECT_ID_DYNAMIC}
echo Project ID: $PROJECT_ID
gcloud iam service-accounts create deploy --display-name "deploy"
gcloud iam service-accounts keys create deploy.key.json --iam-account deploy@$PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding $PROJECT_ID --member "serviceAccount:deploy@$PROJECT_ID.iam.gserviceaccount.com" --role 'roles/owner'
```

#### Enable API's
Enable the API's required to run automated deployment
```
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable sqladmin.googleapis.com
```

### Bastion
#### Place your service account key to your home with name deploy.key.json
```
mv KEY ~/deploy.key.json
```
#### Clone terraforming-gcp repository
Change working directory to current and clone terraform repo for PCF
```
git clone https://github.com/pivotal-cf/terraforming-gcp.git
```

#### Generate certificates
Generate a Certificate Authority and a Private Key
Create applications, system components and login component keys.
(For a development environment you can refer to helper scripts in references)
```
DOMAIN=glpractices.com ./030_gencert.sh 
```
#### Set variables for terraforming solution
Inspect tfvars file and edit the region zone names if necessary
```
DOMAIN=glpractices.com ./041_set_terraforming_vars.sh
```
#### Set variables for self-signeg certificates generation
```
DOMAIN=glpractices.com ./042_set_pcfcerts_vars.sh
```
#### Set variables for self-signeg certificates generation
```
DOMAIN=glpractices.com ./042_set_pcfcerts_vars.sh
```

### Terraform
Deploy the Ops Manager with Terraform
```
cd terraforming-gcp
terraform init
terraform plan -out=plan
terraform apply plan
```

### Pivotal Network
Download PAS, PKS, MYSQL Artifacts and stemcells from network.pivotal.io to the bastion

### Ops Manager
#### BOSH Director for GCP setup
Configure BOSH Director via the wizard.
https://docs.pivotal.io/pivotalcf/2-2/customizing/gcp-om-config-terraform.html
NTP: metadata.google.internal
Add AZs
In networks section use the grep of output to get the details:
```
terraform output | grep -C 1 management
```
Set network name in format: pcf-pcf-network/management/us-central1
Reserve .1 and .2 address (e.g. 10.0.0.1-10.0.0.2)

When set - Apply changes


#### Import artifacts
https://docs.pivotal.io/pivotalcf/2-0/customizing/gcp-om-config-terraform.html
Import installation artifacts. PAS/PKS/MYSQL/Other required.
If you wish to speed up the process, after configuring login and password on Ops Manager node you can use the reference script for local artifact import:

```
USERNAME=admin
PASSWORD=password
ENDPOINT='https://pcf.pcf.glpractices.com'
TOKEN=$(curl -s -k -H 'Accept: application/json;charset=utf-8' -d "grant_type=password" -d "username=$USERNAME" -d "password=$PASSWORD" -u 'opsman:' "${ENDPOINT}/uaa/oauth/token" | jq .access_token | tr -d '"')
echo $TOKEN
curl -vv -H "Authorization: Bearer $TOKEN" -k --verbose --progress-bar -X POST "${ENDPOINT}/api/v0/available_products" -F "product[file]=@sfpas"
```

### Ops Manager/Product installation
#### Deploy Pivotal Application Service
https://docs.pivotal.io/pivotalcf/2-0/customizing/gcp-er-config.html
https://docs.pivotal.io/pivotalcf/2-2/customizing/gcp-er-config-terraform.html

DOMAINS: terraform output | grep domain
LOGIN: Use the certificates generated from pcfcerts folder

Create user:
https://docs.cloudfoundry.org/uaa/uaa-user-management.html

#### Pivotal Container Service
https://docs.pivotal.io/runtimes/pks/1-0/gcp-prepare-env.html

Perform PKS product installation
https://docs.pivotal.io/runtimes/pks/1-0/installing-pks.html

Create user:
https://docs.pivotal.io/runtimes/pks/1-0/manage-users.html

Login to PKS and create cluster:
https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-cli.html#login

### Operations

#### Stop a deployment 
```
bosh deployments
bosh -d cf-XXX stop --hard
bosh -d cf-XXX start
```

#### Save configuration
Go to user -> settings -> Export installation settings..
Save the installation settings and record the encryption key so you will be able to restore your infrastructure when needed.
Note: Please be very careful at each step of Ops Manager Product Installation and consult the referenced documentation. 
Installation process in long and takes a lot of time and attempts.

### Application deployment quickstart
To push a sample application you need to:

- Go to Ops Manager 
- Go to PAS Product
- Open credentials
- Open UAA -> Admin credentials 
- Go to https://apps.env.domain.com and login
- Create organization org1 and space space1
- Download cf cli

Login and push your application:
```
cf login -a api.sys.<env>.<domain> --skip-ssl-validation
cf create-user devuser1 password1
cf set-space-role devuser1 org1 space1 SpaceDeveloper
cf logout
cf login -a api.sys.<env>.<domain> --skip-ssl-validation (as developer)
cf push
```

