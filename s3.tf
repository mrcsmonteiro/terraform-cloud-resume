resource "aws_s3_bucket" "resume_bucket" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "resume_access_block" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "resume_site" {
  bucket = aws_s3_bucket.resume_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "resume_access" {
  bucket = aws_s3_bucket.resume_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudFrontGetObject"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.resume_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })

  # Ensure the public access block is created before the policy
  depends_on = [
    aws_s3_bucket_public_access_block.resume_access_block
  ]
}

# Upload all files from the local 'website' directory
resource "aws_s3_object" "site_files" {
  for_each = toset([for filename in fileset("website/", "**/*") : filename if filename != "favicon.ico"])

  bucket = aws_s3_bucket.resume_bucket.id
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
