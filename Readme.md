# Custom Domain configuration and securing + Wix premium features bypass

![Status](https://img.shields.io/badge/status-active-brightgreen) ![License](https://img.shields.io/badge/license-MIT-blue) ![HTML](https://img.shields.io/badge/HTML-5-orange) ![JavaScript](https://img.shields.io/badge/JavaScript-ES6-yellow)  ![GCP](https://img.shields.io/badge/GCP-Cloud_Storage-blue) ![DNS](https://img.shields.io/badge/DNS-Domain_Registration-lightblue) ![Wix](https://img.shields.io/badge/Wix-Custom_Domain-orange) ![Wix](https://img.shields.io/badge/Wix-Remove_Banner-orange) ![Cloudflare](https://img.shields.io/badge/CloudFlare-SSL-yellowgreen)

---

## Table of Contents

1. [Disclaimer](#disclaimer)  
2. [Overview](#overview)  
3. [Features](#features)  
4. [Prerequisites](#prerequisites)  
5. [GCP Static Website Setup](#gcp-static-website-setup)  
   - [Domain Registration](#domain-registration)  
   - [GCP Configuration](#gcp-configuration)  
   - [Cloudflare Setup](#cloudflare-setup)  
   - [Test the Site](#test-the-site)  
6. [Cloudflare Setup](#cloudflare-setup-1)  
   - [Overview](#overview-1)  
   - [Prerequisites](#prerequisites-1)  
   - [Step-by-Step Guide](#step-by-step-guide)  
7. [Configure Cloudflare WAF Rules](#configure-cloudflare-waf-rules)  
   - [Restrict Traffic to Specific Countries](#restrict-traffic-to-specific-countries)  
   - [Block Access to Unwanted Pages](#block-access-to-unwanted-pages)  
   - [Block Suspicious User Agents](#block-suspicious-user-agents)  
   - [Block Based on Threat Score](#block-based-on-threat-score)  
   - [Block Known Bots](#block-known-bots)  
8. [Test the Configuration](#test-the-configuration)  
9. [Acknowledgments](#acknowledgments)  
10. [License](#license)  

---

## Disclaimer

**This is a research project** designed to showcase how iframe manipulation and DNS configuration can be leveraged to bypass basic free-tier restrictions. The guide is not intended to encourage users to avoid paying for Wix's premium services.

The author assumes **no responsibility** for any misuse of the information provided, including any breach of Wix's terms of service.

While the primary focus is on bypassing certain free-tier restrictions on Wix, the methods presented here for domain configuration, static site hosting, and security via Cloudflare can be repurposed for many other use cases.

---

## Overview

This guide demonstrates how to:  
1. Set up a custom domain and configure DNS.
2. Set up a static website with Google Cloud Storage that will be reached via a custom domain.
3. Host your site using Google Cloud Storage.
4. Configure SSL, Namespace and Firewall through Cloudflare.
5. Iframe manipulation for removing Wix banner on desktop and mobile.

The guide is intended for techincal and non-technical audience. Steps requiring more in-depth knoledge are marked with a ✬ symbol.

---

## Features

- **Custom Domain Integration**  
  Connect your domain to your Wix site by hosting a static website on Google Cloud Storage Bucket.

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

## Step-by-Step Guide

### GCP Static Website Setup

1. **Domain Registration**  
   Purchase and register a domain. Namecheap or GoDaddy are usually suggested.

2. **GCP Configuration**

   2.1. Set up a GCP project. [GCP Free trial credit](https://cloud.google.com/free/docs/free-cloud-features) can be used for our purposes.

   2.2. Set up a GCP bucket for hosting.

       2.2.1. Use the same name as the registered domain with the format `www.my-domain.com`.

       2.2.2. For our private-use, research-purpose project, we select a single region, like `us-central1`.

       2.2.3. Deselect *Enforce public access prevention on this bucket* as we will be granting our file public access.

       ![First Bucket Creation](docs/screenshots/GCP/first_bucket_creation.png)

       2.2.4. ✬ Equivalent gcloud commands:

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
               --website-main-page-suffix=index.html \  # Enable static website hosting.
               --website-not-found-page=404.html
           ```

       2.2.5. *Additional but not required:* Create a storage acting as a backup with the `NEARLINE` storage class for reducing costs and set up a replication policy.

       ![Backup Bucket Creation](docs/screenshots/GCP/backup_bucket_creation.png)

       2.2.5.1. ✬ gcloud commands:

          ```bash
             # Create the second bucket:
             gcloud storage buckets create gs://www-my-domain-backup \
               --location=us-central1 \
               --storage-class=NEARLINE \
               --uniform-bucket-level-access \
               --public-access-prevention
      
             # Enable the Storage Transfer Service API:
             gcloud services enable storagetransfer.googleapis.com
      
             # Set up the IAM roles for the first bucket to allow replication:
             gcloud storage buckets add-iam-policy-binding gs://www.my-domain.com \
               --member=serviceAccount:storage-transfer-service-<YOUR_PROJECT_NUMBER>@gcp-sa-storagetransfer.iam.gserviceaccount.com \
               --role=roles/storage.objectAdmin
      
             # Create the replication policy:
             gcloud storage buckets update gs://www.my-domain.com \
               --add-replication=destination=gs://www-my-domain-backup
          ```

       2.2.6. ✬ A Terraform equivalent, including the `index.html` and `mobile.html` creation, can be found at [main.tf](terraform/main.tf).




### Cloudflare Setup

#### Overview  
This section covers the configuration of HTTPS, DNS, nameservers, and Web Application Firewall (WAF) rules using Cloudflare. The goal is to secure your static website hosted on Google Cloud Platform (GCP) and ensure proper traffic handling.  


#### Prerequisites  
- A Cloudflare account.  
- The domain name registered and added to your Cloudflare account.  
- Access to the DNS management settings in your registrar's dashboard.  


1. **Add Your Domain to Cloudflare**  
   - Log in to your Cloudflare account.  
   - Click on **Add a Site** and enter your domain name (e.g., `my-domain.com`).  
   - Cloudflare will scan your existing DNS records. Verify them and make necessary adjustments.  

2. **Set Up DNS Records**  
   - Add a **CNAME** record pointing from `www.my-domain.com` to the GCP bucket hosting your static website:  
     | Name  | Type  | Content                   | TTL      |
     |-------|-------|---------------------------|----------|
     | www   | CNAME | c.storage.googleapis.com | Auto     |

     - CLI alternative (using Cloudflare API):
       ```bash
       curl -X POST "https://api.cloudflare.com/client/v4/zones/<ZONE_ID>/dns_records" \
       -H "Authorization: Bearer <API_TOKEN>" \
       -H "Content-Type: application/json" \
       --data '{
         "type":"CNAME",
         "name":"www.my-domain.com",
         "content":"c.storage.googleapis.com",
         "ttl":1,
         "proxied":true
       }'
       ```

3. **Change Nameservers**  
   - Cloudflare will provide two nameservers (e.g., `ns1.cloudflare.com` and `ns2.cloudflare.com`).  
   - Update your registrar's DNS settings to point to these nameservers. This change may take up to 48 hours to propagate.  

4. **Enable HTTPS**  
   - In Cloudflare's **SSL/TLS** section, set the mode to **Full** or **Full (strict)** for secure communication.  
   - Toggle **Always Use HTTPS** to automatically redirect HTTP traffic to HTTPS.  

5. **Add Redirect Rules**  
   - Go to the **Rules** section and create the following redirects:
     - **Redirect HTTP to HTTPS**  
       Match: `http://*/*`  
       Redirect to: `https://$1/$2`  
       (Enable "Forwarding URL")  

     - **Redirect Root HTTPS to WWW**  
       Match: `https://my-domain.com/*`  
       Redirect to: `https://www.my-domain.com/$1`  
       (Enable "Forwarding URL")  


#### Configure Cloudflare WAF Rules  

1. **Restrict Traffic to Specific Countries**  
   - Rule: Allow traffic only from IT, SE, DK.  
   - Expression:  
     ```plaintext
     not ip.geoip.country in {"IT","SE","DK"}
     ```

2. **Block Access to Unwanted Pages**  
   - Rule: Block all pages except the allowed ones.  
   - Expression:  
     ```plaintext
     not ends_with(http.request.full_uri, "/") and
     not ends_with(http.request.full_uri, "/favicon.ico") and
     not ends_with(http.request.full_uri, "/mobile.html") and
     not ends_with(http.request.full_uri, ".com")
     ```

3. **Block Suspicious User Agents**  
   - Rule: Block bots, crawlers, and headless browsers.  
   - Expression:  
     ```plaintext
     (http.user_agent contains "bot") or 
     (http.user_agent contains "crawl") or 
     (http.user_agent contains "spider") or 
     (http.user_agent contains "Headless") or 
     (not ssl)
     ```

4. **Block Based on Threat Score**  
   - Rule: Block if threat_score >= 1
   - Expression:  
     ```plaintext
     cf.threat_score ge 1
     ```

5. **Block Known Bots**  
   - Rule: Block all known bots.  
   - Enable the "Known Bots" option in Cloudflare WAF.


#### Test the Configuration  
- Verify that `www.my-domain.com` resolves correctly and loads your static website.  
- Ensure HTTPS is enforced and all redirects work as expected.  
- Test the WAF rules using different countries, user agents, and URLs.


This setup ensures secure and optimized traffic handling for your custom domain, leveraging Cloudflare's powerful tools to enhance the functionality and security of your site.

---

## Acknowledgments

Special thanks to [bobojean](https://github.com/bobojean) and their repository [Hiding-Wix-Ad-for-Free](https://github.com/bobojean/Hiding-Wix-Ad-for-Free) for their initial work on this topic. This guide builds upon and completes their effort.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.  

---
![visitors](https://visitor-badge.laobi.icu/badge?page_id=TdjHJ9zM5k.wix-banner-remover)
