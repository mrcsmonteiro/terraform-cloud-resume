terraform {
  backend "s3" {
    bucket         = "tfstate-resume"
    key            = "terraform/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-lock-table-resume"
    encrypt        = true
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