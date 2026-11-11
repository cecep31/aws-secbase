variable "project" {
  description = "Short project name used in resource names."
  type        = string
  default     = "secbase"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,16}$", var.project))
    error_message = "project must be 2-16 chars of lowercase letters, numbers or hyphens."
  }
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region for the baseline."
  type        = string
  default     = "ap-southeast-1"
}

variable "allowed_account_ids" {
  description = "Optional guard: AWS account IDs this configuration may run against. Empty allows any account."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for id in var.allowed_account_ids : can(regex("^[0-9]{12}$", id))])
    error_message = "Each account ID must be exactly 12 digits (use quotes to keep leading zeros)."
  }
}

variable "alert_emails" {
  description = "Email addresses that receive security alerts."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Days to keep CloudTrail and Config logs in S3. 0 keeps them forever."
  type        = number
  default     = 365
}

variable "securityhub_standards" {
  description = "Security Hub standards: aws-foundational, cis-v3, cis-v1.4, nist-800-53, pci-dss."
  type        = list(string)
  default     = ["aws-foundational", "cis-v3"]
}

variable "tags" {
  description = "Extra tags applied to every resource."
  type        = map(string)
  default     = {}
}
