output "enabled_standards" {
  description = "Enabled standard ARNs."
  value       = [for s in aws_securityhub_standards_subscription.this : s.standards_arn]
}
