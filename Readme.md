# Custom Domain and Ad-Free Wix Sites

![Status](https://img.shields.io/badge/status-active-brightgreen) ![License](https://img.shields.io/badge/license-MIT-blue) ![JavaScript](https://img.shields.io/badge/JavaScript-ES6-yellow)  ![GCP](https://img.shields.io/badge/GCP-Cloud_Storage-blue) ![DNS](https://img.shields.io/badge/DNS-Domain_Registration-lightblue) ![Wix](https://img.shields.io/badge/Wix-Custom_Domain-orange) ![Wix](https://img.shields.io/badge/Wix-Remove_Banner-orange) ![Cloudflare](https://img.shields.io/badge/CloudFlare-SSL-yellowgreen)

## Disclaimer

**This is a research project** designed to explore how multiple technologies can be integrated to host a simple, non-commercial website with minimum cost. The guide is not intended to encourage users to avoid paying for Wix's premium services.

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
  Connect your domain to your Wix site by hosting a static website on Google Cloud Storage with an iframe and a CNAME record pointing to the Cloud Storage file.

- **Ad-Free Experience**  
  Remove the Wix banner for cleaner desktop and mobile presentations.  

- **Static Hosting**  
  Use Google Cloud Storage as a static website host.  

- **Secure Website**  
  Enable HTTPS with Cloudflare SSL.

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
   Purchase and register a domain.  

2. **GCP Configuration**  
   - Set up a GCP bucket for hosting.  
   - Enable static website hosting.  

3. **Cloudflare Setup**  
   - Point DNS to the GCP bucket.  
   - Configure SSL and nameservers.  

4. **Test the Site**  
   Verify that the custom domain is working, the Wix banner is removed, and HTTPS is enabled.  

---

## Acknowledgments

Special thanks to [bobojean](https://github.com/bobojean) and their repository [Hiding-Wix-Ad-for-Free](https://github.com/bobojean/Hiding-Wix-Ad-for-Free) for their initial work on this topic. This guide builds upon and completes their effort.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.  

---
![visitors](https://visitor-badge.laobi.icu/badge?page_id=TdjHJ9zM5k.wix-banner-remover)
