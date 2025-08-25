variable "certfqdn" {
  type = string
}
variable "alt_names" {
  type = list(string)
}

locals {
  # Try to match the pattern; if it fails, return an empty list.
  domain = "${split(".", var.certfqdn)[1]}.${split(".", var.certfqdn)[2]}"
}

# Look up the hosted zone for your domain (e.g., example.com)
data "aws_route53_zone" "zone" {
  name         = "${local.domain}."
  private_zone = false
}
data "aws_region" "current" {}

# Request an ACM certificate for the domain and any SANs
resource "aws_acm_certificate" "cert" {
  domain_name       = var.certfqdn
  validation_method = "DNS"

  # Optional: add any subject alternative names
  subject_alternative_names = var.alt_names
}

resource "aws_ssm_parameter" "certificate_arn" {
  name  = "/certificates/${data.aws_region.current.name}/${replace(replace(var.certfqdn, "*.", ""), ".", "_")}/arn"
  type  = "String"
  value = aws_acm_certificate.cert.arn
}

# Create Route 53 DNS records for validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

# Finalize certificate validation
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.cert_validation.certificate_arn
}

output "certificate_arn_raw" {
  value = aws_acm_certificate.cert.arn
}
