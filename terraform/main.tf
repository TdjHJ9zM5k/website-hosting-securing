provider "google" {
  project = var.project_id
  region  = var.bucket_zone
}

# Create the main bucket
resource "google_storage_bucket" "main_bucket" {
  name                        = var.main_bucket_name
  location                    = var.bucket_zone
  storage_class               = "STANDARD"
  uniform_bucket_level_access = false
  website {
    main_page_suffix = "index.html"
  }
}

# Create the backup bucket
resource "google_storage_bucket" "backup_bucket" {
  name                        = "backup-${var.main_bucket_name}"
  location                    = var.bucket_zone
  storage_class               = "NEARLINE"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

# Grant IAM roles for the main bucket
resource "google_storage_bucket_iam_member" "main_bucket_admin" {
  bucket = google_storage_bucket.main_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:project-${data.google_project.project.project_number}@storage-transfer-service.iam.gserviceaccount.com"
}

# Grant IAM roles for data transfer at the project level
resource "google_project_iam_member" "storage_transfer_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:project-${data.google_project.project.project_number}@storage-transfer-service.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "pubsub_editor" {
  project = var.project_id
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:project-${data.google_project.project.project_number}@storage-transfer-service.iam.gserviceaccount.com"
}

# Grant IAM roles for the Cloud Storage service account
resource "google_project_iam_member" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.project_number}@gs-project-accounts.iam.gserviceaccount.com"
}

# Enable the Storage Transfer Service API
resource "google_project_service" "storagetransfer" {
  project = var.project_id
  service = "storagetransfer.googleapis.com"
}

# Data block to get project details dynamically
data "google_project" "project" {
  project_id = var.project_id
}
