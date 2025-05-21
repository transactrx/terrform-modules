variable "desitination_domain" {
  type = string
}
variable "public_dns_name" {
  type = string
}
variable "name" {
  type = string
}
variable "acm_certificate_arn" {
  type = string
}
variable "origin_request_policy_id" {
  type = string
}
variable "cache_policy_id" {
  type = string
}
variable "waf_protection_arn" {
  type = string
}
variable "origin_read_timeout" {
  type = number
  default = 30
}
variable "origin_keepalive_timeout" {
  type = number
  default = 5
}

# CloudFront Distribution using the new policies
# The `resource "aws_cloudfront_distribution" "proxy"` block is defining an AWS CloudFront distribution resource named "proxy".
# This resource configuration specifies the settings for a CloudFront distribution, including the origin server configuration, aliases (alternate domain names), cache behaviors, SSL certificate, restrictions, and other properties.
resource "aws_cloudfront_distribution" "proxy" {
  origin {
    domain_name = var.desitination_domain # Fixed typo: "desitination_domain" -> "destination_domain"
    origin_id   = var.name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = var.origin_keepalive_timeout
      origin_read_timeout      = var.origin_read_timeout
    }
  }

  aliases = [var.public_dns_name]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "/" # Optional: Remove if not needed

  default_cache_behavior {
    target_origin_id       = var.name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true # Optional but recommended

    # Attach both the cache policy and the origin request policy
    cache_policy_id          = var.cache_policy_id
    origin_request_policy_id = var.origin_request_policy_id
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist" # Allow access from all locations
      locations = [
        "US",
      ]
    }
  }

  web_acl_id = var.waf_protection_arn
}

output "domain_name" {
  value = aws_cloudfront_distribution.proxy.domain_name
}
output "zone_id" {
  value = aws_cloudfront_distribution.proxy.hosted_zone_id
}
