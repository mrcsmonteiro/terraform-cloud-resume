terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

resource "aws_s3_bucket" "resume-bucket" {
  bucket = "mms.211125568316.realhandsonlabs.net"

  tags = {
    Name        = "Name"
    Environment = "resume-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "resume-public-access" {
  bucket = aws_s3_bucket.resume-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "resume-site" {
  bucket = aws_s3_bucket.resume-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "resume-access" {
  bucket = aws_s3_bucket.resume-bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.resume-bucket.arn}/*"
      }
    ]
  })
}

# Upload all files from the local 'website' directory
resource "aws_s3_object" "site-files" {
  for_each = fileset("website/", "**/*")

  bucket = aws_s3_bucket.resume-bucket.id
  key    = each.value
  source = "website/${each.value}"

  # This is crucial for detecting changes and re-uploading files.
  etag = filemd5("website/${each.value}")

  # Set the content type based on the file extension
  content_type = lookup(
    {
      "html" = "text/html",
      "css"  = "text/css",
      "js"   = "application/javascript",
      "png"  = "image/png",
      "jpg"  = "image/jpeg",
      "svg"  = "image/svg+xml",
      "ico"  = "image/x-icon"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
}