# Custom Domain and Ad-Free Wix Sites

![Status](https://img.shields.io/badge/status-active-brightgreen) ![License](https://img.shields.io/badge/license-MIT-blue) ![JavaScript](https://img.shields.io/badge/JavaScript-ES6-yellow)  ![GCP](https://img.shields.io/badge/GCP-Cloud_Storage-blue) ![DNS](https://img.shields.io/badge/DNS-Domain_Registration-lightblue) ![Wix](https://img.shields.io/badge/Wix-Custom_Domain-orange) ![Wix](https://img.shields.io/badge/Wix-Remove_Banner-orange) ![Cloudflare](https://img.shields.io/badge/CloudFlare-SSL-yellowgreen)

## Disclaimer

**This is a research project** designed to showcase how iframe manipulation and dns configuration can be leveraged to bypass basic free-tier restrictions. The guide is not intended to encourage users to avoid paying for Wix's premium services.

The author assumes **no responsibility** for any misuse of the information provided, including any breach of Wix's terms of service.

---

## Overview

This guide demonstrates how to:  
1. Set up a custom domain.  
2. Iframe manipolation for desktop and mobile.  
3. Host your site using Google Cloud Storage.
4. Configure SSL, DNS and Firewall through Cloudflare.

---

## Features

- **Custom Domain Integration**  
  Connect your domain to your Wix site by hosting a static website on Google Cloud Storage with an iframe. Add a CNAME record pointing to the Cloud Storage file.

- **Free-tier Banner Removing**  
  Remove the Wix banner for cleaner desktop and mobile presentations.

- **Static Hosting**  
  Use Google Cloud Storage as a static website host.  

- **Secure Website**  
  Implement HTTPS and WAF with Cloudflare.

---

## Prerequisites

To use this guide, you'll need:  
- A registered domain name.  
- Access to Google Cloud Platform (GCP).  
- A Cloudflare account.  
- Basic understanding of DNS and hosting.  

---

## Steps

1. **Domain Registration**  
   Purchase and register a domain. Namecheap or GoDaddy are usually suggested.

2. **GCP Configuration**
   - Set up a GCP project. [GCP Free trial credit](https://cloud.google.com/free/docs/free-cloud-features) can be used for our purposes.
   - Set up a GCP bucket for hosting.
     - Use the same name as the registered domain with the format www.my-domain.com
     - For our private-use, research-purpose project, we select single region, like us-central1
     - Deselect *Enforce public access prevention on this bucket* as we will be granting our file public access.
     - Equivalent gcloud commands:
       ```bash
        gcloud config set project <YOUR_PROJECT_ID>  # Replace with your actual project ID
        # Set the region to us-central1
        gcloud config set compute/region us-central1  

        # Create the bucket
        gcloud storage buckets create gs://www.my-domain.com \
          --location=us-central1 \
          --storage-class=STANDARD \
          --no-uniform-bucket-level-access \
          --public-access-prevention=disabled \
          --website-main-page-suffix=index.html \  #Enable static website hosting.
          --website-not-found-page=404.html
       ```
     - *Addional but not required:* create a storage acting as a backup with nearline storage class for reducing costs.
       ```bash
        #Create the second bucket:
        gcloud storage buckets create gs://www-my-domain-backup \
          --location=us-central1 \
          --storage-class=NEARLINE \
          --uniform-bucket-level-access \
          --public-access-prevention

        #Enable the Storage Transfer Service API:
        gcloud services enable storagetransfer.googleapis.com

        #Set up the IAM roles for the first bucket to allow replication:
        gcloud storage buckets add-iam-policy-binding gs://www.my-domain.com \
          --member=serviceAccount:storage-transfer-service-<YOUR_PROJECT_NUMBER>@gcp-sa-storagetransfer.iam.gserviceaccount.com \
          --role=roles/storage.objectAdmin

        #Create the replication policy:
        gcloud storage buckets update gs://www.my-domain.com \
          --add-replication=destination=gs://www-my-domain-backup
       ```
     - A terraform equivalent, including the index.html and mobile.html creation, can be found at [main.tf](terraform/main.tf)

4. **Cloudflare Setup**  
   - Point DNS to the GCP bucket.  
   - Configure SSL and nameservers.  

5. **Test the Site**  
   Verify that the custom domain is working, the Wix banner is removed, and HTTPS is enabled.  

---

## Acknowledgments

Special thanks to [bobojean](https://github.com/bobojean) and their repository [Hiding-Wix-Ad-for-Free](https://github.com/bobojean/Hiding-Wix-Ad-for-Free) for their initial work on this topic. This guide builds upon and completes their effort.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.  

---
![visitors](https://visitor-badge.laobi.icu/badge?page_id=TdjHJ9zM5k.wix-banner-remover)
