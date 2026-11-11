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
  http_put_response_hop_limit = var.imds_hop_limit
}

resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = var.access_analyzer_name
  type          = "ACCOUNT"
  tags          = var.tags
}

# CIS 5.4: the default security group of every default VPC must not allow any traffic.
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
