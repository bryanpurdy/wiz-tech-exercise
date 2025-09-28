# Wiz Technical Exercise – Runbook

This document outlines the step-by-step process to deploy the Tasky application in CloudLabs and prepare for the Wiz demo.

---

## 1. Activate CloudLabs AWS Account
- Log in to [wiz.cloudlabs.ai](https://wiz.cloudlabs.ai).
- Redeem activation code.
- Confirm AWS account, region, and temporary credentials.

---

## 2. Deploy Infrastructure with Terraform
```bash
cd infra
terraform init
terraform validate
terraform apply
