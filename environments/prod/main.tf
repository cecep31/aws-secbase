data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  name       = "${var.project}-${var.environment}"

  log_bucket_name = "${local.name}-security-logs-${local.account_id}"
  trail_name      = "${local.name}-trail"
  # Built from known values so the bucket policy does not depend on the trail itself.
  trail_arn = "arn:${local.partition}:cloudtrail:${var.region}:${local.account_id}:trail/${local.trail_name}"

  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "opentofu"
  })
}

# ---------------------------------------------------------------- logging

module "log_key" {
  source = "../../modules/kms"

  alias                = "alias/${local.name}-security-logs"
  description          = "Encrypts CloudTrail, Config snapshots and security alerts"
  allow_cloudtrail     = true
  allow_sns_publishers = true
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

  bucket_name      = local.log_bucket_name
  kms_key_arn      = module.log_key.key_arn
  policy_documents = [data.aws_iam_policy_document.log_bucket.json]
  expiration_days  = var.log_retention_days
}

module "cloudtrail" {
  source = "../../modules/cloudtrail"

  name = local.trail_name
  # CloudTrail validates the bucket policy on creation; this output waits for it.
  s3_bucket_name = module.log_bucket.id
  kms_key_arn    = module.log_key.key_arn
}

# ---------------------------------------------------------------- detection

module "config" {
  source = "../../modules/config"

  role_name      = "${local.name}-aws-config"
  s3_bucket_name = module.log_bucket.id
  s3_bucket_arn  = module.log_bucket.arn
  kms_key_arn    = module.log_key.key_arn
}

module "guardduty" {
  source = "../../modules/guardduty"
}

module "securityhub" {
  source = "../../modules/securityhub"

  standards = var.securityhub_standards
}

# ---------------------------------------------------------------- hardening

module "hardening" {
  source = "../../modules/hardening"

  access_analyzer_name = "${local.name}-analyzer"
}

# ---------------------------------------------------------------- alerting

module "alerting" {
  source = "../../modules/alerting"

  name         = "${local.name}-security-alerts"
  kms_key_arn  = module.log_key.key_arn
  alert_emails = var.alert_emails
}
