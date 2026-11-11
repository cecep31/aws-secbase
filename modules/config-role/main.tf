data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "delivery" {
  statement {
    sid       = "WriteSnapshots"
    actions   = ["s3:PutObject"]
    resources = ["${var.s3_bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"]
  }

  statement {
    sid       = "CheckBucket"
    actions   = ["s3:GetBucketAcl", "s3:ListBucket"]
    resources = [var.s3_bucket_arn]
  }

  statement {
    sid       = "UseLogKey"
    actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "delivery" {
  name   = "config-delivery"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.delivery.json
}
