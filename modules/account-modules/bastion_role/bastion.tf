variable "name" {

}
resource "aws_iam_role" "bastion" {
  name = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = var.name
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.bastion.name
}

output "role_name" {
  value = aws_iam_role.bastion.name
}
output "role_arn" {
  value = aws_iam_role.bastion.arn
}
output "instance_profile" {
  value = aws_iam_instance_profile.bastion.name
}
