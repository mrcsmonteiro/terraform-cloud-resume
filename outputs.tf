output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "api_invoke_url" {
  value = "${aws_api_gateway_stage.prod_stage.invoke_url}/visitors"
}

output "cloudfront_alias" {
  description = "CloudFront distribution alternate domain name (CNAME)"
  value       = "https://${aws_route53_record.resume_alias.name}"
}