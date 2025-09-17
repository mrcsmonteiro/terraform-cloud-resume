data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone
  private_zone = false
}

# Create an A record for the "resume" subdomain.
# The type is "A" for an IPv4 address record.
# The record is configured as an ALIAS to point to the CloudFront distribution.
resource "aws_route53_record" "resume_alias" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.alias_hosted_zone
  type    = "A"

  # The alias block is used to point to an AWS resource.
  # The "name" is the DNS name of the CloudFront distribution.
  # The "zone_id" for a CloudFront distribution is a hard-coded value.
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }

  depends_on = [
    aws_cloudfront_distribution.s3_distribution
  ]
}