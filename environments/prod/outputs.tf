output "log_bucket" {
  description = "Central bucket for CloudTrail and Config."
  value       = module.log_bucket.id
}

output "log_kms_key_arn" {
  description = "KMS key that encrypts security logs and alerts."
  value       = module.log_key.key_arn
}

output "cloudtrail_arn" {
  description = "Multi-region CloudTrail ARN."
  value       = module.cloudtrail.trail_arn
}

output "alerts_topic_arn" {
  description = "SNS topic for security alerts. Subscribe Slack/PagerDuty/etc. here."
  value       = module.alerting.sns_topic_arn
}

output "guardduty_detectors" {
  description = "GuardDuty detector ID per region."
  value       = { for r, m in module.regional_baseline : r => m.guardduty_detector_id }
}

output "covered_regions" {
  description = "Regions with the regional baseline."
  value       = sort(tolist(local.regions))
}
