output "recorder_name" {
  description = "Name of the configuration recorder."
  value       = aws_config_configuration_recorder.this.name
}
