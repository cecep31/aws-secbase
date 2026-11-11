output "state_bucket" {
  description = "Bucket for remote state."
  value       = module.state_bucket.id
}

output "state_kms_key_arn" {
  description = "KMS key for state. Put it in environments/prod/terraform.tfvars as state_kms_key_id."
  value       = module.state_key.key_arn
}
