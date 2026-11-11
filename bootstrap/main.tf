# Creates the S3 bucket and KMS key for remote state. Run once; its own state stays local.

provider "aws" {
  region = var.region
  # Refuses to run against an unexpected account when the list is set.
  allowed_account_ids = length(var.allowed_account_ids) > 0 ? var.allowed_account_ids : null

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "opentofu"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  name = "${var.project}-tfstate"
}

module "state_key" {
  source = "../modules/kms"

  alias       = "alias/${local.name}"
  description = "OpenTofu state for ${var.project}"
}

module "state_bucket" {
  source = "../modules/secure-bucket"

  bucket_name                   = "${local.name}-${data.aws_caller_identity.current.account_id}-${var.region}"
  kms_key_arn                   = module.state_key.key_arn
  transition_to_glacier_ir_days = 0
  expiration_days               = 0
}
