# CloudFront Origin Access Control (OAC)
# This grants CloudFront permission to access the S3 bucket
#
resource "aws_cloudfront_origin_access_control" "static_site_oac" {
  name                              = "${local.bucket_name}-oac"
  description                       = "OAC for S3 bucket ${local.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # domain names CloudFront should respond to.
  aliases = [var.domain_name]

  # Origin Configuration: Link the CloudFront distribution to the S3 bucket
  origin {
    domain_name = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    origin_id   = "S3-${local.bucket_name}"
    # Attach the OAC to the origin
    origin_access_control_id = aws_cloudfront_origin_access_control.static_site_oac.id
  }

  # Default Cache Behavior: Defines how CloudFront handles requests
  default_cache_behavior {
    target_origin_id = "S3-${local.bucket_name}"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = true # Forward query strings
      cookies {
        forward = "none" # Do not forward cookies
      }
    }

    # Default settings for caching
    min_ttl     = 0
    default_ttl = 3600  # 1 hour
    max_ttl     = 86400 # 24 hours
  }

  # Viewer Certificate: Use the default CloudFront certificate
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.resume_cert_validation.certificate_arn
    ssl_support_method  = "sni-only"
  }

  # Add custom error responses for a more user-friendly experience
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/404.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}