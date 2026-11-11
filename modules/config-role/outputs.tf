output "role_arn" {
  description = "ARN of the AWS Config role."
  value       = aws_iam_role.this.arn
}
