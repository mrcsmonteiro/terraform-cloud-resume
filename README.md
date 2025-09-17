![AWS_Terraform_Cloud_Resume](AWS_Terraform_Cloud_Resume.png)

![Static Badge](https://img.shields.io/badge/Terraform-v1.13.2-blue) ![Static Badge](https://img.shields.io/badge/AWS_CLI-2.27.49-blue) ![Static Badge](https://img.shields.io/badge/Python-3.13.4-blue)

## Table of Contents
- [Overview](#overview)
- [Usage](#usage)

## Overview

This Terraform project provisions the infrastructure for a serverless cloud resume. It uses AWS services to deploy a static website with a visitor counter. The architecture includes an S3 bucket for hosting the website, a DynamoDB table for storing visitor data, and a CloudFront distribution to serve the content securely. An API Gateway, integrated with two Lambda functions, handles the visitor count logic. The project also configures DNS records with Route 53 and automates deployments using GitHub Actions with OIDC for secure access.

### Core Components

- **AWS S3**: Hosts the static website files.
- **AWS CloudFront**: Serves the website securely with HTTPS and caches content for fast delivery.
- **AWS DynamoDB**: A NoSQL database storing the website visitor count.
- **AWS Lambda**: Two functions handle the API logic: one for retrieving the count and another for incrementing it.
- **AWS API Gateway**: Exposes the Lambda functions as a REST API, managing requests and CORS.
- **AWS Route 53**: Manages DNS records to point the custom domain to the CloudFront distribution.
- **AWS IAM**: Configures roles and policies for secure communication between services and for GitHub Actions.
- **GitHub Actions**: An OIDC-enabled workflow automates the deployment of the infrastructure and website.

## Usage

To use this Terraform project, you'll need the following prerequisites installed and configured:
- **Terraform (v1.13.0+)**: The infrastructure as code tool.
- **AWS CLI**: For authenticating and interacting with your AWS account.
- **Git**: To clone the repository.

You must also have an existing **Route 53 Hosted Zone** and a **validated ACM certificate** in the `us-east-1` region for your domain, as this project assumes their existence.

### Configuration

1. Clone the repository:
   ```bash
   git clone https://github.com/mrcsmonteiro/terraform-cloud-resume.git
   cd terraform-cloud-resume
   ```
2. **Edit** `terraform.tfvars`: Create a `terraform.tfvars` file and populate it with your specific details. This file overrides the default values in `variables.tf`.
   ```Terraform
   aws_region                     = "ap-southeast-2"
   aws_account_id                 = "123456789012"
   project                        = "YourProjectName"
   hosted_zone                    = "yourdomain.com."
   alias_hosted_zone              = "resume.yourdomain.com."
   domain_name                    = "resume.yourdomain.com"
   existing_acm_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/xyz-123"
   ```
3. **Review the Lambda Code and customize your website assets**: The project requires two Python Lambda function files, `lambda_get_visitor_count.py` and `lambda_increment_visitor_count.py` available in the codebase, and a website directory `website/` with an `index.html.tpl` file and other static assets. Ensure these are present in the root directory. The `index.html.tpl` is a template file that includes the API Gateway endpoint dynamically to the embedded JavaScript code and generates the HTML file. This is required to enable the visitor count functionality.

### Deployment

The code available in the `prod` branch is designed for automated deployment via **GitHub Actions** using **OpenID Connect (OIDC)**. To deploy, push your changes to the `prod` branch. The configured workflow will automatically provision or update the AWS resources.

Alternatively, you can deploy the infrastructure manually from your local machine:

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Review the plan:
   ```bash
   terraform plan
   ```
3. Apply the changes:
   ```bash
   terraform apply
   ```