output "backend_config" {
  description = "Paste this into environments/prod/backend.hcl."
  value       = <<-EOT
    bucket       = "${module.state_bucket.id}"
    key          = "security-baseline/prod/terraform.tfstate"
    region       = "${var.region}"
    encrypt      = true
    kms_key_id   = "${module.state_key.key_arn}"
    use_lockfile = true
  EOT
}
