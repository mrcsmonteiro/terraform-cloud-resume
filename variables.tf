variable "aws_region" {
  type        = string
  description = "AWS region to use for resources."
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
  default     = "891377289799.realhandsonlabs.net."
}

variable "domain_name" {
  type        = string
  description = "Cloud resume domain name"
  default     = "resume.891377289799.realhandsonlabs.net"
}