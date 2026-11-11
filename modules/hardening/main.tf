# ---------------------------------------------------------------- IAM

resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
}

resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = var.access_analyzer_name
  type          = "ACCOUNT"
  tags          = var.tags
}

# ---------------------------------------------------------------- S3

resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------- EC2 / EBS

resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

resource "aws_ebs_snapshot_block_public_access" "this" {
  state = "block-all-sharing"
}

resource "aws_ec2_image_block_public_access" "this" {
  state = "block-new-sharing"
}

# New instances default to IMDSv2 only.
resource "aws_ec2_instance_metadata_defaults" "this" {
  http_tokens                 = "required"
  http_put_response_hop_limit = 2
}

# ---------------------------------------------------------------- default VPC
# CIS: the default security group must not allow any traffic.

data "aws_vpcs" "default" {
  filter {
    name   = "is-default"
    values = ["true"]
  }
}

resource "aws_default_security_group" "this" {
  for_each = var.restrict_default_security_groups ? toset(data.aws_vpcs.default.ids) : toset([])

  vpc_id = each.value
  tags   = merge(var.tags, { Name = "default-restricted" })
}
