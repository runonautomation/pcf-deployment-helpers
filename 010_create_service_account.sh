PROJECT_ID_DYNAMIC=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
PROJECT_ID=${GCP_PROJECT_ID:-$PROJECT_ID_DYNAMIC}
echo Project ID: $PROJECT_ID
gcloud iam service-accounts create deploy --display-name "deploy"
gcloud iam service-accounts keys create deploy.key.json --iam-account deploy@$PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding $PROJECT_ID --member "serviceAccount:deploy@$PROJECT_ID.iam.gserviceaccount.com" --role 'roles/owner'