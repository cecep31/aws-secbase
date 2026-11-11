module "guardduty" {
  source = "../guardduty"

  features = var.guardduty_features
  tags     = var.tags
}

module "securityhub" {
  source = "../securityhub"

  standards         = var.securityhub_standards
  aggregate_regions = var.is_home_region ? var.aggregate_regions : []
}

module "config" {
  source = "../config"

  role_arn                      = var.config_role_arn
  s3_bucket_name                = var.log_bucket_name
  include_global_resource_types = var.is_home_region
  rules                         = merge(var.config_rules, var.is_home_region ? var.config_global_rules : {})
  tags                          = var.tags
}

module "hardening" {
  source = "../regional-hardening"

  access_analyzer_name             = var.access_analyzer_name
  restrict_default_security_groups = var.restrict_default_security_groups
  tags                             = var.tags
}
