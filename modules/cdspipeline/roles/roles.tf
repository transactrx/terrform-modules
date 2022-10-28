variable "attachedPolicies" {
  type = list(string)
}
variable "name" {
  type = string
}
variable "servicePrinciple" {
  type = string
}


resource "aws_iam_role" "role" {
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = var.servicePrinciple
        }
      },
    ]
  })
  name = var.name
}

resource "aws_iam_role_policy_attachment" "attachments" {
  count      = length(var.attachedPolicies)
  policy_arn = var.attachedPolicies[count.index]
  role       = aws_iam_role.role.name
}

output "roleArn" {
  value = aws_iam_role.role.arn
}
output "roleName" {
  value = aws_iam_role.role.name
}