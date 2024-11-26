provider "google" {
  project = "<YOUR_PROJECT_ID>" # Replace with your project ID
  region  = "us-central1"
}

# Hosting bucket with fine-grained access and static website configuration
resource "google_storage_bucket" "hosting_bucket" {
  name          = "www.my-domain.com" # Replace with your domain name
  location      = "us-central1"
  storage_class = "STANDARD"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  # Fine-grained access
  uniform_bucket_level_access = false
  public_access_prevention    = "DISABLED"
}

# Backup bucket with uniform access and NEARLINE storage class
resource "google_storage_bucket" "backup_bucket" {
  name          = "www-my-domain-backup"
  location      = "us-central1"
  storage_class = "NEARLINE"
  force_destroy = true

  # Uniform access control
  uniform_bucket_level_access = true
  public_access_prevention    = "ENFORCED"
}

# Upload index.html to hosting bucket
resource "google_storage_bucket_object" "index_html" {
  name   = "index.html"
  bucket = google_storage_bucket.hosting_bucket.name
  content = <<EOT
<!DOCTYPE html>
<html>
  <head>
    <title>My Custom Title</title>
    <link rel="icon" href="https://storage.googleapis.com/www.my-website.com/favicon.ico" type="image/x-icon">
  </head>
  <body>
    <iframe src="https://username.wixsite.com/name" style="position:fixed; top:-50px; left:0px; bottom:0px; right:0px; width:100%; height:105%; border:none; margin:0; padding:0; overflow:hidden; z-index:999999;"></iframe>
    <script type="text/javascript">
      if (screen.width <= 900) {
        document.location = "/mobile.html";
      }
    </script>
  </body>
</html>
EOT
}

# Upload mobile.html to hosting bucket
resource "google_storage_bucket_object" "mobile_html" {
  name   = "mobile.html"
  bucket = google_storage_bucket.hosting_bucket.name
  content = <<EOT
<!DOCTYPE html>
<html>
  <head>
    <title>My Custom Title</title>
    <link rel="icon" href="https://storage.googleapis.com/www.my-website.com/favicon.ico" type="image/x-icon">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      iframe {
        position: fixed;
        left: 0;
        top: -39px;
        width: 100%;
        height: calc(100% + 39px);
        border: none;
      }
      body {
        margin: 0;
        padding: 0;
      }
    </style>
  </head>
  <body>
    <iframe src="https://username.wixsite.com/name" style="position: fixed; left: 0px; top: -39px; width: 100%; height: 108%;"></iframe>
    <script>
      function resizeIframe() {
        const iframe = document.querySelector('iframe');
        const screenWidth = window.innerWidth;
        const screenHeight = window.innerHeight;

        const baseWidth = 320;
        const baseTop = -39;
        const scaleFactor = screenWidth / baseWidth;

        iframe.style.transform = \`scale(${scaleFactor})\`;
        iframe.style.transformOrigin = "top left";

        iframe.style.width = \`\${baseWidth}px\`;
        const newHeight = (screenHeight / scaleFactor) - (baseTop * scaleFactor);
        iframe.style.height = \`\${newHeight}px\`;
        iframe.style.left = \`calc((100vw - \${baseWidth}px * \${scaleFactor}) / 2)\`;
        iframe.style.top = \`\${baseTop * scaleFactor}px\`;
      }

      document.addEventListener('DOMContentLoaded', resizeIframe);

      let resizeTimeout;
      window.addEventListener('resize', () => {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(resizeIframe, 100);
      });
    </script>
  </body>
</html>
EOT
}

# Enable the Storage Transfer Service API
resource "google_project_service" "enable_transfer_service" {
  project = "<YOUR_PROJECT_ID>" # Replace with your project ID
  service = "storagetransfer.googleapis.com"
}

# IAM policy for the first bucket to allow replication
resource "google_storage_bucket_iam_member" "replication_iam_policy" {
  bucket = google_storage_bucket.hosting_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:storage-transfer-service-<YOUR_PROJECT_NUMBER>@gcp-sa-storagetransfer.iam.gserviceaccount.com"
}

# Cross-bucket replication
resource "google_storage_bucket_replication" "cross_bucket_replication" {
  source_bucket      = google_storage_bucket.hosting_bucket.name
  destination_bucket = google_storage_bucket.backup_bucket.name
}
