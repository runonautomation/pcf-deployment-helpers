## Deployment playbook and documentation links

During the evaluation DevOps practice tried the available ways to deploy PCF on Google Cloud Platform, and came to conclusion that recommended approach is to use GCP terraform scripts to deploy the platform. 
Below you can find an action reference playbook for start the platform installation from scratch on your account:


### DNS
Register a DNS zone for your deployment.
Example dns zone: pcf.domain.com
You can expect that PCF services will be registered as:
pcf.pcf.domain.com (Ops Manager)
*.apps.pcf.domain.com


### GCP
Deploy a GCP project or two projects if you wish to keep terraform automation in a separate project.
Deploy a bastion host in a separate network that will have the deployment prerequisites installed.
Create deployment service account in Cloud Shell

```
gcloud iam service-accounts create deploy --display-name "deploy"
gcloud iam service-accounts keys create deploy.key.json --iam-account deploy@$PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding $PROJECT_ID --member "serviceAccount:deploy@$PROJECT_ID.iam.gserviceaccount.com" --role 'roles/owner'
```


### Bastion / CA / Keys
Generate a Certificate Authority and a Private Key
Create applications, system components and login component keys.
(For a development environment you can refer to helper scripts in references)
Prepare the environment
https://docs.pivotal.io/pivotalcf/2-0/customizing/gcp-prepare-env-terraform.html


### Bastion/Terraform solution environment

Clone the Operations Manager repository:

```git clone https://github.com/pivotal-cf/terraforming-gcp.git```

Bastion/Terraform
https://docs.pivotal.io/pivotalcf/2-0/customizing/gcp-terraform.html

After applying the needed configuration, apply the terraform configuration  

### Pivotal Network
Download PAS, PKS, MYSQL Artifacts and stemcells from network.pivotal.io to the bastion
Ops Manager
Configure Ops Manager and Ops Manager Director for GCP
https://docs.pivotal.io/pivotalcf/2-0/customizing/gcp-om-config-terraform.html


### Ops Manager/Artifacts
Import installation artifacts. PAS/PKS/MYSQL/Other required.

Login to Ops Manager and import products via UI using import product button

Tip:
If you wish to speed up the process, after configuring login and password on Ops Manager node you can use the reference script for local artifact import:

```
curl -s -k -H 'Accept: application/json;charset=utf-8' -d 'grant_type=password' -d 'username=admin' -d 'password=PASSWORD' -u 'opsman:' https://localhost/uaa/oauth/token
export T="TOKEN HERE"
curl -vv -H "Authorization: bearer $T" -k -X POST https://localhost/api/v0/available_products -F 'product[file]=@/home/volodymyr_davydenko/srt-2.1.5-build.1.pivotal'
```

### Ops Manager/Product installation
Deploy Pivotal Application Service
https://docs.pivotal.io/pivotalcf/2-0/customizing/gcp-er-config.html

Create user:
https://docs.cloudfoundry.org/uaa/uaa-user-management.html
Login to PAS

Ops Manager/Product installation
Pivotal Container Service, prepare for GCP installation
https://docs.pivotal.io/runtimes/pks/1-0/gcp-prepare-env.html

Perform PKS product installation
https://docs.pivotal.io/runtimes/pks/1-0/installing-pks.html

Create user:
https://docs.pivotal.io/runtimes/pks/1-0/manage-users.html

Login to PKS and create cluster:
https://docs.pivotal.io/runtimes/pks/1-0/installing-pks-cli.html#login

Mysql Ops Manager/Product installation
https://docs.pivotal.io/p-mysql/2-1/install-config.html



### Configuration Saving
Go to user -> settings -> Export installation settings..
Save the installation settings and record the encryption key so you will be able to restore your infrastructure when needed.

Note: Please be very careful at each step of Ops Manager Product Installation and consult the referenced documentation. 
Installation process in long and takes a lot of time and attempts.


## Application deployment quickstart
To push a sample application you need to:

Go to Ops Manager 
Go to PAS Product
Open credentials
Open UAA -> Admin credentials 
Go to https://apps.env.domain.com and login
Create organization org1 and space space1
Download cf cli
```
cf login -a api.sys.<env>.<domain> --skip-ssl-validation
Select the created space
cf create-user devuser1 password1
cf set-space-role devuser1 org1 space1 SpaceDeveloper
cf logout
cf login -a api.sys.<env>.<domain> --skip-ssl-validation (as developer)
cf push
```

