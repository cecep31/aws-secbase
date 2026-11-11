data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  prefix = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.region}::standards"

  standard_arns = {
    aws-foundational = "${local.prefix}/aws-foundational-security-best-practices/v/1.0.0"
    cis-v3           = "${local.prefix}/cis-aws-foundations-benchmark/v/3.0.0"
    "cis-v1.4"       = "${local.prefix}/cis-aws-foundations-benchmark/v/1.4.0"
    nist-800-53      = "${local.prefix}/nist-800-53/v/5.0.0"
    pci-dss          = "${local.prefix}/pci-dss/v/3.2.1"
  }
}

resource "aws_securityhub_account" "this" {
  enable_default_standards  = false
  auto_enable_controls      = true
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each = toset(var.standards)

  standards_arn = local.standard_arns[each.key]

  depends_on = [aws_securityhub_account.this]
}

# Pulls findings from the linked regions into this one so alerts only need one place.
resource "aws_securityhub_finding_aggregator" "this" {
  count = length(var.aggregate_regions) > 0 ? 1 : 0

  linking_mode      = "SPECIFIED_REGIONS"
  specified_regions = var.aggregate_regions

  depends_on = [aws_securityhub_account.this]
}
