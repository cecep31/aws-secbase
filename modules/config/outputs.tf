output "recorder_name" {
  description = "Name of the configuration recorder."
  value       = aws_config_configuration_recorder.this.name
}

output "rule_names" {
  description = "Config rules created in this region."
  value       = keys(aws_config_config_rule.this)
}
