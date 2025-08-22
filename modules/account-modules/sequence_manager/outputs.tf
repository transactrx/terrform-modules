#############################################
# Outputs (safe for both modes)
#############################################

output "table_name" {
  description = "(provision) DynamoDB table name (null in claim mode)."
  value       = length(aws_dynamodb_table.seq) > 0 ? aws_dynamodb_table.seq[0].name : null
}

output "lambda_name" {
  description = "(provision) Lambda name (null in claim mode)."
  value       = length(aws_lambda_function.claim) > 0 ? aws_lambda_function.claim[0].function_name : null
}

output "function_url" {
  description = "(provision) Function URL if created (else null)."
  value       = length(aws_lambda_function_url.this) > 0 ? aws_lambda_function_url.this[0].function_url : null
}

output "lambda_pointer_written" {
  description = "(provision) SSM parameter where Lambda name is published."
  value       = length(aws_ssm_parameter.lambda_pointer) > 0 ? aws_ssm_parameter.lambda_pointer[0].name : null
}

output "priority" {
  description = "(claim) Your stable ALB listener rule priority (e.g., 10, 20, 30...). Null in provision mode."
  value       = length(aws_ssm_parameter.claimed_priority) > 0 ? tonumber(aws_ssm_parameter.claimed_priority[0].value) : null
}

output "claimed_parameter" {
  description = "(claim) SSM parameter storing your claimed priority."
  value       = length(aws_ssm_parameter.claimed_priority) > 0 ? aws_ssm_parameter.claimed_priority[0].name : null
}
