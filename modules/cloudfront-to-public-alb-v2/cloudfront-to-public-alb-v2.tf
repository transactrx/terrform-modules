###########################
# Variables
###########################

variable "name" {
  type        = string
  description = "Name for the CloudFront distribution and associated resources."
}

variable "destination_domain" {
  type        = string
  description = "Origin domain name (e.g., the ALB internal hostname)."
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate for CloudFront to use."
}

variable "waf_protection_id" {
  type        = string
  description = "ARN of the WAF WebACL to associate with the distribution."
}

variable "cloudfront_aliases" {
  type        = list(string)
  description = <<-EOT
    All domain names (aliases) this CloudFront distribution serves.
    These are added to the CloudFront distribution's Aliases list.
    Example: ["www.example.com", "example.com"]
  EOT
}

variable "dns_hostnames" {
  type        = list(string)
  description = <<-EOT
    Hostnames to create Route53 A records for, pointing to this CloudFront distribution.
    Separate from cloudfront_aliases to allow managing DNS independently.
    Leave empty to skip DNS record creation entirely.
  EOT
  default     = []
}

variable "geo_restriction_locations" {
  type        = list(string)
  description = "List of country codes for geo restriction whitelist."
  default     = ["US"]
}

variable "origin_protocol_policy" {
  type        = string
  description = "Protocol policy for origin requests: http-only, https-only, or match-viewer."
  default     = "match-viewer"
}

variable "origin_ssl_protocols" {
  type        = list(string)
  description = "SSL/TLS protocols for origin connections."
  default     = ["TLSv1.2"]
}

variable "cache_default_ttl" {
  type        = number
  description = "Default TTL for cached objects in seconds."
  default     = 3
}

variable "cache_max_ttl" {
  type        = number
  description = "Maximum TTL for cached objects in seconds."
  default     = 3
}

variable "cache_min_ttl" {
  type        = number
  description = "Minimum TTL for cached objects in seconds."
  default     = 3
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources created by this module."
  default     = {}
}

###########################
# Locals
###########################

locals {
  # Per-hostname zone name (last two labels of each FQDN)
  dns_hostname_zone_names = {
    for h in var.dns_hostnames :
    h => join(".", slice(split(".", h), length(split(".", h)) - 2, length(split(".", h))))
  }

  # Sanitize name for use in policy names (replace non-alphanumeric with dash)
  sanitized_name = replace(var.name, "/[^a-zA-Z0-9]/", "-")
}

###########################
# Origin Request Policy
###########################

resource "aws_cloudfront_origin_request_policy" "all_policy" {
  name = "ForwardAllPolicy-${local.sanitized_name}"

  headers_config {
    header_behavior = "allViewer"
  }

  query_strings_config {
    query_string_behavior = "all"
  }

  cookies_config {
    cookie_behavior = "all"
  }
}

###########################
# Cache Policy
###########################

resource "aws_cloudfront_cache_policy" "forward_all" {
  name        = "ForwardAllCachePolicy-${local.sanitized_name}"
  comment     = "Cache policy that forwards all query strings, cookies, and headers"
  default_ttl = var.cache_default_ttl
  max_ttl     = var.cache_max_ttl
  min_ttl     = var.cache_min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Authorization"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
    cookies_config {
      cookie_behavior = "all"
    }
  }
}

###########################
# CloudFront Distribution
###########################

resource "aws_cloudfront_distribution" "proxy" {
  origin {
    domain_name = var.destination_domain
    origin_id   = var.name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = var.origin_protocol_policy
      origin_ssl_protocols     = var.origin_ssl_protocols
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  aliases = var.cloudfront_aliases

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    target_origin_id       = var.name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    cache_policy_id          = aws_cloudfront_cache_policy.forward_all.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_policy.id
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.geo_restriction_locations
    }
  }

  web_acl_id = var.waf_protection_id

  tags = var.tags
}

###########################
# Route53 DNS Records
###########################

data "aws_route53_zone" "dns_zones" {
  for_each     = length(var.dns_hostnames) > 0 ? toset(var.dns_hostnames) : toset([])
  name         = local.dns_hostname_zone_names[each.value]
  private_zone = false
}

resource "aws_route53_record" "dns" {
  for_each        = toset(var.dns_hostnames)
  zone_id         = data.aws_route53_zone.dns_zones[each.value].zone_id
  name            = each.value
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.proxy.domain_name
    zone_id                = aws_cloudfront_distribution.proxy.hosted_zone_id
    evaluate_target_health = false
  }
}

###########################
# Outputs
###########################

output "domain_name" {
  value       = aws_cloudfront_distribution.proxy.domain_name
  description = "CloudFront distribution domain name."
}

output "zone_id" {
  value       = aws_cloudfront_distribution.proxy.hosted_zone_id
  description = "CloudFront distribution hosted zone ID."
}

output "distribution_id" {
  value       = aws_cloudfront_distribution.proxy.id
  description = "CloudFront distribution ID."
}

output "distribution_arn" {
  value       = aws_cloudfront_distribution.proxy.arn
  description = "CloudFront distribution ARN."
}
