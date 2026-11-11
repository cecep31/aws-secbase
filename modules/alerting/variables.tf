variable "name" {
  description = "Name of the SNS topic and prefix for EventBridge rules."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key used to encrypt the SNS topic."
  type        = string
}

variable "alert_emails" {
  description = "Email addresses subscribed to security alerts. Each must confirm the subscription."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for e in var.alert_emails : can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", e))])
    error_message = "alert_emails must contain valid email addresses."
  }
}

variable "cloudtrail_log_group_name" {
  description = "CloudWatch log group that receives CloudTrail events."
  type        = string
}

variable "enable_cis_alarms" {
  description = "Create the CIS metric filters and alarms."
  type        = bool
  default     = true
}

variable "metric_namespace" {
  description = "CloudWatch namespace for the CIS metrics."
  type        = string
  default     = "CISBenchmark"
}

variable "securityhub_alert_severities" {
  description = "Security Hub severity labels that trigger an alert."
  type        = list(string)
  default     = ["CRITICAL", "HIGH"]

  validation {
    condition     = alltrue([for s in var.securityhub_alert_severities : contains(["INFORMATIONAL", "LOW", "MEDIUM", "HIGH", "CRITICAL"], s)])
    error_message = "Valid severities: INFORMATIONAL, LOW, MEDIUM, HIGH, CRITICAL."
  }
}

variable "tags" {
  description = "Tags for created resources."
  type        = map(string)
  default     = {}
}
