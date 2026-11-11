output "password_minimum_length" {
  description = "Applied minimum password length."
  value       = aws_iam_account_password_policy.this.minimum_password_length
}
