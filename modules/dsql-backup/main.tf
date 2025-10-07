############################################
# VARIABLES
############################################

variable "name_prefix" {
  description = "Prefix for all backup-related resources (e.g., transactrx-dsql)"
  type        = string
}

variable "resource_arns" {
  description = "List of ARNs for resources to include in the backup selection"
  type        = list(string)
}

variable "schedule" {
  description = "CRON schedule for the backup plan (UTC time)"
  type        = string
  default     = "cron(0 5 ? * * *)" # Daily at 5 AM UTC
}

variable "delete_after_days" {
  description = "Number of days after which backups are deleted"
  type        = number
  default     = 35
}

############################################
# IAM ROLE & TRUST POLICY
############################################

data "aws_iam_policy_document" "backup_trust" {
  statement {
    sid     = "AWSBackupAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup_role" {
  name               = "AWSBackupFor-${var.name_prefix}"
  assume_role_policy = data.aws_iam_policy_document.backup_trust.json
  description        = "Role assumed by AWS Backup to back up ${var.name_prefix} resources"
  path               = "/"
}

# Attach AWS managed policy for backup service role
resource "aws_iam_role_policy_attachment" "backup_policy_attachment" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

############################################
# BACKUP VAULT
############################################

resource "aws_backup_vault" "backup_vault" {
  name = "${var.name_prefix}-vault"
}

############################################
# BACKUP PLAN
############################################

resource "aws_backup_plan" "backup_plan" {
  name = "${var.name_prefix}-plan"

  rule {
    rule_name         = "${var.name_prefix}-rule"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = var.schedule

    lifecycle {
      delete_after = var.delete_after_days
    }
  }
}

############################################
# BACKUP SELECTION
############################################

resource "aws_backup_selection" "backup_selection" {
  name         = "${var.name_prefix}-selection"
  plan_id      = aws_backup_plan.backup_plan.id
  iam_role_arn = aws_iam_role.backup_role.arn
  resources    = var.resource_arns
}

############################################
# OUTPUTS
############################################

output "backup_role_arn" {
  value = aws_iam_role.backup_role.arn
}

output "backup_vault_name" {
  value = aws_backup_vault.backup_vault.name
}

output "backup_plan_id" {
  value = aws_backup_plan.backup_plan.id
}