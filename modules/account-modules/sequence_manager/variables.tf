#############################################
# Shared inputs
#############################################

variable "mode" {
  description = "Use 'provision' to create the shared counter; 'claim' for services to get their number."
  type        = string
  validation {
    condition     = contains(["provision", "claim"], var.mode)
    error_message = "mode must be 'provision' or 'claim'."
  }
}

# Where we publish/read the Lambda name pointer (regional SSM)
variable "lambda_pointer_ssm_name" {
  description = "SSM parameter name that stores the sequence Lambda function name."
  type        = string
  default     = "/ras/shared/sequence_lambda_name"
}

variable "tags" {
  type        = map(string)
  default     = {}
}

#############################################
# Provision-mode inputs (ignored in claim mode)
#############################################

variable "table_name" {
  description = "(provision) DynamoDB table name."
  type        = string
  default     = "ras-sequences"
}

variable "billing_mode" {
  description = "(provision) DynamoDB billing mode."
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "billing_mode must be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "point_in_time_recovery" {
  description = "(provision) Enable PITR for the table."
  type        = bool
  default     = true
}

variable "lambda_name" {
  description = "(provision) Lambda function name to create."
  type        = string
  default     = "ras-claim-next-seq"
}

variable "create_function_url" {
  description = "(provision) Create Lambda Function URL."
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "(provision) Function URL auth type."
  type        = string
  default     = "AWS_IAM"
  validation {
    condition     = contains(["AWS_IAM", "NONE"], var.function_url_auth_type)
    error_message = "function_url_auth_type must be AWS_IAM or NONE."
  }
}

#############################################
# Claim-mode inputs (ignored in provision mode)
#############################################

variable "sequence_name" {
  description = "(claim) Logical sequence name (e.g., 'alb-main:443'). One per listener."
  type        = string
  default     = null
}

variable "service_name" {
  description = "(claim) Service identifier, used in persisted parameter path."
  type        = string
  default     = null
}

variable "step" {
  description = "(claim) Increment size. 10 -> 10,20,30,... for ALB priorities."
  type        = number
  default     = 10
  validation {
    condition     = var.step >= 1 && var.step <= 1000
    error_message = "step must be between 1 and 1000."
  }
}

variable "claim_parameter_prefix" {
  description = "(claim) SSM prefix where the claimed value is stored."
  type        = string
  default     = "/ras/services"
}
