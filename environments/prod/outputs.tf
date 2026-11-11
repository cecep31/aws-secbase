output "log_bucket" {
  description = "Bucket for CloudTrail and Config logs."
  value       = module.log_bucket.id
}

output "cloudtrail_arn" {
  description = "Multi-region CloudTrail ARN."
  value       = module.cloudtrail.trail_arn
}

output "alerts_topic_arn" {
  description = "SNS topic for security alerts."
  value       = module.alerting.sns_topic_arn
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID."
  value       = module.guardduty.detector_id
}
