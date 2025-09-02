locals {
  common_tags = {
    Project = var.project
  }

  bucket_name = var.domain_name
}