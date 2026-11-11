output "sns_topic_arn" {
  description = "ARN of the security alerts topic."
  value       = aws_sns_topic.this.arn
}

output "cis_alarm_names" {
  description = "Names of the CIS CloudWatch alarms."
  value       = [for a in aws_cloudwatch_metric_alarm.cis : a.alarm_name]
}
