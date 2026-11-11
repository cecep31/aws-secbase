variable "name" {
  description = "Name of the SNS topic and prefix for the EventBridge rule."
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

variable "severities" {
  description = "Security Hub severity labels that trigger an alert."
  type        = list(string)
  default     = ["CRITICAL", "HIGH"]

  validation {
    condition     = alltrue([for s in var.severities : contains(["INFORMATIONAL", "LOW", "MEDIUM", "HIGH", "CRITICAL"], s)])
    error_message = "Valid severities: INFORMATIONAL, LOW, MEDIUM, HIGH, CRITICAL."
  }
}

variable "tags" {
  description = "Tags for created resources."
  type        = map(string)
  default     = {}
}
