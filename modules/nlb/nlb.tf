variable "name" {
  type = string
}
variable "private" {
  type = bool
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

variable "subnetIds" {
  type = list(string)
}


data "aws_iam_policy_document" "s3_lb_write" {

  statement {
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.nlbAccessLogBucket.arn}/logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals  {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type        = "AWS"
    }
  }
}

resource "aws_s3_bucket" "nlbAccessLogBucket" {
  bucket =lower("nlbaccesslogs-${var.name}-${data.aws_caller_identity.current.account_id}")

}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.nlbAccessLogBucket.id
  policy = data.aws_iam_policy_document.s3_lb_write.json
}



resource "aws_alb" "nlb" {
  name               = var.name
  internal           = var.private
  load_balancer_type = "network"
  subnets            = var.subnetIds

  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
  access_logs {
    bucket = aws_s3_bucket.nlbAccessLogBucket.bucket
    prefix = "logs"
    enabled = true
  }

}


output "nlb_arn" {
  value = aws_alb.nlb.arn
}
output "nlb_name" {
  value = aws_alb.nlb.name
}
output "nlb_dns_name" {
  value = aws_alb.nlb.dns_name
}