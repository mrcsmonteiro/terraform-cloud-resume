variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "ap-southeast-2"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
  default     = "460637121552"
}

variable "acm_region" {
  type        = string
  description = "AWS region for ACM certificate (must be us-east-1 for CloudFront)"
  default     = "us-east-1"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
  default     = "Terraform AWS Cloud Resume"
}

variable "hosted_zone" {
  type        = string
  description = "Public hosted zone ID"
  default     = "marcosms.com.au."
}

variable "alias_hosted_zone" {
  type        = string
  description = "Public hosted zone ID"
  default     = "resume.marcosms.com.au."
}

variable "sub_domain_name" {
  type        = string
  description = "Cloud resume domain name"
  default     = "resume"
}

variable "domain_name" {
  type        = string
  description = "Cloud resume domain name"
  default     = "resume.marcosms.com.au"
}

variable "existing_acm_certificate_arn" {
  description = "The ARN of existing ACM certificate for the domain."
  type        = string
  default     = "arn:aws:acm:us-east-1:460637121552:certificate/eabe8a0c-142d-4591-83d2-2ff6ba8c08e4"
}

variable "log_prefix" {
  type        = string
  description = "Prefix for CloudFront logs in S3 bucket"
  default     = "static-site-logs/"
}