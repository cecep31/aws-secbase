provider "aws" {
  region = var.region
  # Refuses to run against an unexpected account when the list is set.
  allowed_account_ids = length(var.allowed_account_ids) > 0 ? var.allowed_account_ids : null

  default_tags {
    tags = local.tags
  }
}
