variable "name" {
  description = "Base name for resources"
  type        = string
}

variable "private-subnet-ids" {
  description = "Private subnet IDs (as string)"
  type = string
}

variable "vpc-id" {
  description = "VPC ID"
  type = string
}

variable "branch_name" {
  description = "GitHub branch pattern to allow"
  type = string
}

variable "identity_provider_arn" {
  description = "ARN of the existing GitHub OIDC provider (optional)"
  type        = string
  default     = null
}

variable "region" {
  type        = string
  description = "Optional suffix to append to resource names for regional scoping (e.g., 'west')."
  default     = ""
}