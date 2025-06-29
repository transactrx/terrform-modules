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

variable "waf_protection_id" {
  type = string
}


# Origin Request Policy: Forward all headers, query strings, and cookies to the origin
resource "aws_cloudfront_origin_request_policy" "all_policy" {
  name = "ForwardAllPolicy${var.name}"

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

# Cache Policy: Define cache key parameters (even if caching is disabled)
resource "aws_cloudfront_cache_policy" "forward_all" {
  name        = "ForwardAllCachePolicy${var.name}"
  comment     = "Cache policy that forwards all query strings, cookies, and headers"
  default_ttl = 3
  max_ttl     = 3
  min_ttl     = 3

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Authorization"] # Forward all headers
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
      origin_protocol_policy   = "match-viewer"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5  # Optional but recommended
      origin_read_timeout      = 30 # Optional but recommended
    }


  }


  aliases = [var.public_dns_name]

  enabled             = true
  is_ipv6_enabled     = true
  # default_root_object removed to prevent redirect loops with dynamic applications

  default_cache_behavior {
    target_origin_id       = var.name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true # Optional but recommended

    # Attach both the cache policy and the origin request policy
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
      restriction_type = "whitelist" # Allow access from all locations
      locations = [
        "US",
      ]
    }
  }

  web_acl_id = var.waf_protection_id
}

# add cloudfront domain name to route53

locals {
  # Split the FQDN into parts, then join the last two segments as the zone name.
  dns_parts = split(".", var.public_dns_name)
  zone_name = join(".", slice(local.dns_parts, length(local.dns_parts) - 2, length(local.dns_parts)))
  hostname  = local.dns_parts[0]
}

data "aws_route53_zone" "public" {
  name         = local.zone_name
  private_zone = false
}

#register the dns name
resource "aws_route53_record" "cf_alias" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.hostname # e.g., "www.example.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.proxy.domain_name
    zone_id                = aws_cloudfront_distribution.proxy.hosted_zone_id
    evaluate_target_health = false

  }
}


output "domain_name" {
  value = aws_cloudfront_distribution.proxy.domain_name
}
output "zone_id" {
  value = aws_cloudfront_distribution.proxy.hosted_zone_id
}
