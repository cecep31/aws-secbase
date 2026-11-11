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
  name                      = "security-alerts"
  kms_key_arn               = "arn:aws:kms:ap-southeast-1:123456789012:key/00000000-0000-0000-0000-000000000000"
  cloudtrail_log_group_name = "/aws/cloudtrail/example"
  alert_emails              = ["security@example.com"]
}

run "creates_all_cis_alarms" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.cis) == 15
    error_message = "Expected 15 CIS alarms."
  }

  assert {
    condition     = aws_sns_topic.this.kms_master_key_id == var.kms_key_arn
    error_message = "The alert topic must be encrypted with the given KMS key."
  }

  assert {
    condition     = length(aws_sns_topic_subscription.email) == 1
    error_message = "One email subscription expected."
  }
}

run "cis_alarms_can_be_disabled" {
  command = plan

  variables {
    enable_cis_alarms = false
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.cis) == 0
    error_message = "No CIS alarms expected when disabled."
  }
}

run "rejects_bad_email" {
  command = plan

  variables {
    alert_emails = ["not-an-email"]
  }

  expect_failures = [var.alert_emails]
}
