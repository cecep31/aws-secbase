output "sns_topic_arn" {
  description = "ARN of the security alerts topic."
  value       = aws_sns_topic.this.arn
}
