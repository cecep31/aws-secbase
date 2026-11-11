output "trail_arn" {
  description = "ARN of the trail."
  value       = aws_cloudtrail.this.arn
}

output "log_group_name" {
  description = "CloudWatch log group that receives the trail."
  value       = aws_cloudwatch_log_group.this.name
}
