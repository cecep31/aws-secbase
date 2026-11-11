output "trail_arn" {
  description = "ARN of the trail."
  value       = aws_cloudtrail.this.arn
}
