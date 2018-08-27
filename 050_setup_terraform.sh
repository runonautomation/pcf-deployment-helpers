command -v yum || apt install -y unzip
command -v apt || yum install -y unzip
curl https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip > terraform.zip
unzip terraform.zip
mv terraform /usr/local/bin/