# Set the project name
PROJECT_ID=<YOUR_PROJECT_ID>

# Set the main bucket
MAIN_BUCKET_NAME="www.my-domain.com" #Change it to your registered domain

# Set the bucket zone
BUCKET_ZONE="us-central1"

# Dynamically create the backup bucket name
BACKUP_BUCKET_NAME="backup-${MAIN_BUCKET_NAME}"

# Dynamically get the project ID
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")

# Set the active project
gcloud config set project "$PROJECT_ID"

# Create the main bucket
gcloud storage buckets create "gs://${MAIN_BUCKET_NAME}" \
  --location=${BUCKET_ZONE} \
  --default-storage-class=STANDARD \
  --no-public-access-prevention \
  --no-uniform-bucket-level-access

# Configure access to use index.html as the main page
gcloud storage buckets update "gs://${MAIN_BUCKET_NAME}" --web-main-page-suffix=index.html

# Create the backup bucket
gcloud storage buckets create "gs://${BACKUP_BUCKET_NAME}" \
  --location=${BUCKET_ZONE} \
  --default-storage-class=NEARLINE \
  --public-access-prevention \
  --uniform-bucket-level-access

# Enable the Storage Transfer Service API
gcloud services enable storagetransfer.googleapis.com

# Set up IAM roles for data transfer
TRANSFER_SERVICE_ACCOUNT="project-${PROJECT_NUMBER}@storage-transfer-service.iam.gserviceaccount.com"
STORAGE_SERVICE_ACCOUNT="service-${PROJECT_NUMBER}@gs-project-accounts.iam.gserviceaccount.com"

# Grant IAM roles for the main bucket
gcloud storage buckets add-iam-policy-binding "gs://${MAIN_BUCKET_NAME}" \
  --member="serviceAccount:${TRANSFER_SERVICE_ACCOUNT}" \
  --role="roles/storage.admin"

# Grant IAM roles to the project for data transfer
gcloud projects add-iam-policy-binding "$PROJECT_NUMBER" \
  --member="serviceAccount:${TRANSFER_SERVICE_ACCOUNT}" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding "$PROJECT_NUMBER" \
  --member="serviceAccount:${TRANSFER_SERVICE_ACCOUNT}" \
  --role="roles/pubsub.editor"

# Grant IAM roles to the Cloud Storage service account
gcloud projects add-iam-policy-binding "$PROJECT_NUMBER" \
  --member="serviceAccount:${STORAGE_SERVICE_ACCOUNT}" \
  --role="roles/pubsub.publisher"

# Create the replication job
gcloud alpha transfer jobs create "gs://${MAIN_BUCKET_NAME}" "gs://${BACKUP_BUCKET_NAME}" --replication

# List active replication jobs
gcloud alpha transfer jobs list --job-type=replication
