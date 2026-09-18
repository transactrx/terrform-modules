// New variables on ecs, aurora-postgres and alb-public exist so clinicalplus_aws
// can retire its vendored module copies. Every one of them defaults to the
// module's pre-existing behavior, so the accounts already on these modules must
// see an identical plan. These runs pin that guarantee, and also prove the
// variables actually take effect when a consumer sets them.

mock_provider "aws" {}

# ---------------------------------------------------------------- ecs

run "ecs_default_leaves_container_insights_unmanaged" {
  providers = { aws = aws }
  command   = plan
  module { source = "../../modules/account-modules/ecs" }
  variables {
    name = "parity-cluster"
  }
  assert {
    condition     = length(aws_ecs_cluster.cluster.setting) == 0
    error_message = "With container_insights unset the cluster must emit no setting block, or clusters already running enhanced insights would be changed."
  }
}

run "ecs_container_insights_applies_when_set" {
  providers = { aws = aws }
  command   = plan
  module { source = "../../modules/account-modules/ecs" }
  variables {
    name               = "parity-cluster"
    container_insights = "enhanced"
  }
  assert {
    condition     = length(aws_ecs_cluster.cluster.setting) == 1 && one(aws_ecs_cluster.cluster.setting).name == "containerInsights" && one(aws_ecs_cluster.cluster.setting).value == "enhanced"
    error_message = "container_insights must drive the containerInsights cluster setting."
  }
}

# ------------------------------------------------------ aurora-postgres

run "aurora_defaults_match_previous_behavior" {
  providers = { aws = aws }
  command   = plan
  module { source = "../../modules/account-modules/aurora-postgres" }
  variables {
    name       = "parity"
    vpc_id     = "vpc-0123456789abcdef0"
    vpc_cidr   = "10.1.0.0/20"
    subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  }
  assert {
    condition     = one(aws_security_group.aurora_sg.ingress).cidr_blocks == tolist(["10.1.0.0/20"])
    error_message = "Without additional_ingress_cidrs the Postgres ingress rule must still allow only the VPC CIDR."
  }
  # backup_retention_period and performance_insights_enabled are deliberately
  # not asserted here. Both are Optional+Computed in the AWS provider, so with
  # the variables left null the plan reports them as "known after apply" rather
  # than a concrete value -- which is exactly the property that keeps existing
  # clusters unchanged. The override run below proves the variables work.
}

run "aurora_accepts_cross_account_cidrs_and_overrides" {
  providers = { aws = aws }
  command   = plan
  module { source = "../../modules/account-modules/aurora-postgres" }
  variables {
    name                         = "parity"
    vpc_id                       = "vpc-0123456789abcdef0"
    vpc_cidr                     = "10.1.16.0/20"
    subnet_ids                   = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    additional_ingress_cidrs     = ["10.106.0.0/16"]
    backup_retention_period      = 30
    performance_insights_enabled = true
  }
  assert {
    condition     = one(aws_security_group.aurora_sg.ingress).cidr_blocks == tolist(["10.1.16.0/20", "10.106.0.0/16"])
    error_message = "additional_ingress_cidrs must be allowed alongside the VPC CIDR, which is how the Batch account reaches the database."
  }
  assert {
    condition     = aws_rds_cluster.aurora_postgres_cluster.backup_retention_period == 30
    error_message = "backup_retention_period must reach the cluster when set."
  }
  assert {
    condition     = aws_rds_cluster_instance.aurora_postgres_instance[0].performance_insights_enabled == true
    error_message = "performance_insights_enabled must reach the cluster instances when set."
  }
}

# ----------------------------------------------------------- alb-public

run "alb_default_response_matches_previous_behavior" {
  providers = { aws = aws }
  command   = plan
  module { source = "../../modules/account-modules/alb-public" }
  variables {
    name                        = "parity-alb"
    vpc_id                      = "vpc-0123456789abcdef0"
    vpc_cidr_block              = "10.1.0.0/20"
    domain_suffix               = "io"
    ecs_cluster_name            = "parity-cluster"
    public_subnetIds            = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    certificate_arn             = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"
    additional_certificate_arns = []
  }
  assert {
    condition     = one(one(aws_lb_listener.defaultListener443.default_action).fixed_response).content_type == "text/plain" && one(one(aws_lb_listener.defaultListener443.default_action).fixed_response).message_body == "Forbidden" && one(one(aws_lb_listener.defaultListener443.default_action).fixed_response).status_code == "403"
    error_message = "The :443 default fixed response must keep returning a plain-text 403 Forbidden unless a consumer overrides it."
  }
}

run "alb_default_response_is_overridable" {
  providers = { aws = aws }
  command   = plan
  module { source = "../../modules/account-modules/alb-public" }
  variables {
    name                          = "parity-alb"
    vpc_id                        = "vpc-0123456789abcdef0"
    vpc_cidr_block                = "10.1.0.0/20"
    domain_suffix                 = "io"
    ecs_cluster_name              = "parity-cluster"
    public_subnetIds              = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    certificate_arn               = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"
    additional_certificate_arns   = []
    default_response_content_type = "text/html"
    default_response_body         = "<html><body><h1>Service Unavailable</h1></body></html>"
    default_response_status_code  = "503"
  }
  assert {
    condition     = one(one(aws_lb_listener.defaultListener443.default_action).fixed_response).status_code == "503" && one(one(aws_lb_listener.defaultListener443.default_action).fixed_response).content_type == "text/html"
    error_message = "A consumer must be able to override the default fixed response."
  }
}
