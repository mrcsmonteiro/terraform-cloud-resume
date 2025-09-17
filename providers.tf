# Main region
provider "aws" {
  region = var.aws_region
  alias  = "us-east-1"
}

# ACM certificate region
provider "aws" {
  region = var.acm_region
  alias  = "acm-region"
}