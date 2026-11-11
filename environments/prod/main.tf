data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  name       = "${var.project}-${var.environment}"
  regions    = toset(distinct(concat([var.home_region], var.additional_regions)))
  # Providers outlive their resources by one apply when a region is retired.
  provider_regions = setunion(local.regions, toset(var.regions_pending_removal))

  log_bucket_name        = "${local.name}-security-logs-${local.account_id}"
  access_log_bucket_name = "${local.name}-s3-access-logs-${local.account_id}"
  trail_name             = "${local.name}-trail"
  # Built from known values so the bucket policy does not depend on the trail itself.
  trail_arn = "arn:${local.partition}:cloudtrail:${var.home_region}:${local.account_id}:trail/${local.trail_name}"

  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "opentofu"
  })
}

# ---------------------------------------------------------------- encryption

module "log_key" {
  source = "../../modules/kms"

  alias                 = "alias/${local.name}-security-logs"
  description           = "Encrypts CloudTrail, CloudWatch Logs, Config and SNS alerts"
  allow_cloudtrail      = true
  allow_cloudwatch_logs = true
  allow_sns_publishers  = true
}

# ---------------------------------------------------------------- log buckets

data "aws_iam_policy_document" "access_logs_bucket" {
  statement {
    sid       = "S3ServerAccessLogs"
    actions   = ["s3:PutObject"]
    resources = ["arn:${local.partition}:s3:::${local.access_log_bucket_name}/*"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

module "access_logs_bucket" {
  source = "../../modules/secure-bucket"

  bucket_name      = local.access_log_bucket_name
  kms_key_arn      = null # S3 server access logs only support SSE-S3 targets
  policy_documents = [data.aws_iam_policy_document.access_logs_bucket.json]
  expiration_days  = var.access_log_retention_days
}

data "aws_iam_policy_document" "log_bucket" {
  statement {
    sid       = "CloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:${local.partition}:s3:::${local.log_bucket_name}"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  statement {
    sid       = "CloudTrailWrite"
    actions   = ["s3:PutObject"]
    resources = ["arn:${local.partition}:s3:::${local.log_bucket_name}/AWSLogs/${local.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }
}

module "log_bucket" {
  source = "../../modules/secure-bucket"

  bucket_name                   = local.log_bucket_name
  kms_key_arn                   = module.log_key.key_arn
  access_log_bucket             = module.access_logs_bucket.id
  policy_documents              = [data.aws_iam_policy_document.log_bucket.json]
  transition_to_glacier_ir_days = var.log_transition_days
  expiration_days               = var.log_retention_days
}

# ---------------------------------------------------------------- global resources

module "cloudtrail" {
  source = "../../modules/cloudtrail"

  name = local.trail_name
  # CloudTrail validates the bucket policy on creation; this output waits for it.
  s3_bucket_name                = module.log_bucket.id
  kms_key_arn                   = module.log_key.key_arn
  cloudwatch_log_retention_days = var.cloudtrail_log_group_retention_days
  enable_s3_data_events         = var.cloudtrail_s3_data_events
}

module "account_hardening" {
  source = "../../modules/account-hardening"
}

module "config_role" {
  source = "../../modules/config-role"

  name          = "${local.name}-aws-config"
  s3_bucket_arn = module.log_bucket.arn
  kms_key_arn   = module.log_key.key_arn
}

# ---------------------------------------------------------------- per-region baseline

module "regional_baseline" {
  source   = "../../modules/regional-baseline"
  for_each = local.regions

  providers = {
    aws = aws.regional[each.key]
  }

  is_home_region    = each.key == var.home_region
  aggregate_regions = [for r in local.regions : r if r != var.home_region]

  log_bucket_name     = module.log_bucket.id
  config_role_arn     = module.config_role.role_arn
  config_rules        = var.config_rules
  config_global_rules = var.config_global_rules

  guardduty_features    = var.guardduty_features
  securityhub_standards = var.securityhub_standards
  access_analyzer_name  = "${local.name}-analyzer"
}

# ---------------------------------------------------------------- alerting

module "alerting" {
  source = "../../modules/alerting"

  name                         = "${local.name}-security-alerts"
  kms_key_arn                  = module.log_key.key_arn
  alert_emails                 = var.alert_emails
  cloudtrail_log_group_name    = module.cloudtrail.log_group_name
  securityhub_alert_severities = var.securityhub_alert_severities
}
