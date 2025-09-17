terraform {
  backend "s3" {
    bucket       = "tfstate-resume"
    key          = "terraform/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = "terraform-lock-table"
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}