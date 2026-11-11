provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

data "aws_caller_identity" "current" {}

locals {
  name       = "${var.project}-tfstate"
  account_id = data.aws_caller_identity.current.account_id
  tags = {
    Project   = var.project
    ManagedBy = "opentofu"
    Component = "bootstrap"
  }
}

# Encrypts the S3 bucket and is used by OpenTofu client-side state encryption.
module "state_key" {
  source = "../modules/kms"

  alias       = "alias/${local.name}"
  description = "OpenTofu state encryption for ${var.project}"
}

module "state_bucket" {
  source = "../modules/secure-bucket"

  bucket_name                        = "${local.name}-${local.account_id}-${var.region}"
  kms_key_arn                        = module.state_key.key_arn
  transition_to_glacier_ir_days      = 0
  expiration_days                    = 0
  noncurrent_version_expiration_days = 365
}

resource "local_file" "backend_config" {
  filename        = "${path.module}/../environments/prod/backend.hcl"
  file_permission = "0640"
  content         = <<-EOT
    bucket       = "${module.state_bucket.id}"
    key          = "security-baseline/prod/terraform.tfstate"
    region       = "${var.region}"
    encrypt      = true
    kms_key_id   = "${module.state_key.key_arn}"
    use_lockfile = true
  EOT
}
