variable "destination_domain" {
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
variable "vpc_origin_id" {
  type        = string
  description = "ID of the aws_cloudfront_vpc_origin created separately"
}

resource "aws_cloudfront_distribution" "proxy" {
  origin {
    domain_name = var.destination_domain
    origin_id   = var.name
    vpc_origin_config {
      vpc_origin_id = var.vpc_origin_id
    }
  }

  aliases = [var.public_dns_name]
  enabled = true
  is_ipv6_enabled = true
  default_root_object = "/"

  default_cache_behavior {
    target_origin_id       = var.name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true
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
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  web_acl_id = var.waf_protection_arn
}

# Keep outputs the same
output "domain_name" {
  value = aws_cloudfront_distribution.proxy.domain_name
}
output "zone_id" {
  value = aws_cloudfront_distribution.proxy.hosted_zone_id
}