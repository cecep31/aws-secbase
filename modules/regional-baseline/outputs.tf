output "guardduty_detector_id" {
  description = "GuardDuty detector ID."
  value       = module.guardduty.detector_id
}

output "securityhub_standards" {
  description = "Enabled Security Hub standards."
  value       = module.securityhub.enabled_standards
}

output "config_rules" {
  description = "Config rules in this region."
  value       = module.config.rule_names
}
