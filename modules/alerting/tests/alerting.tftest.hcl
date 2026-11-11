mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_resource "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:ap-southeast-1:123456789012:security-alerts"
    }
  }
}

variables {
  name         = "security-alerts"
  kms_key_arn  = "arn:aws:kms:ap-southeast-1:123456789012:key/00000000-0000-0000-0000-000000000000"
  alert_emails = ["security@example.com"]
}

run "topic_is_encrypted_and_subscribed" {
  command = plan

  assert {
    condition     = aws_sns_topic.this.kms_master_key_id == var.kms_key_arn
    error_message = "The alert topic must be encrypted with the given KMS key."
  }

  assert {
    condition     = length(aws_sns_topic_subscription.email) == 1
    error_message = "One email subscription expected."
  }
}

run "rejects_bad_email" {
  command = plan

  variables {
    alert_emails = ["not-an-email"]
  }

  expect_failures = [var.alert_emails]
}
