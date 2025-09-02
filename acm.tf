resource "aws_acm_certificate" "resume_cert" {
  provider          = aws.us-east-1
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = local.common_tags
  lifecycle {
    create_before_destroy = true
  }
}

# Wait for the certificate to be validated.
resource "aws_acm_certificate_validation" "resume_cert_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.resume_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.resume_cert_validation : record.fqdn]
}