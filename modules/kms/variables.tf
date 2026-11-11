variable "alias" {
  description = "KMS alias, must start with alias/."
  type        = string

  validation {
    condition     = startswith(var.alias, "alias/") && !startswith(var.alias, "alias/aws/")
    error_message = "alias must start with \"alias/\" and must not use the reserved \"alias/aws/\" prefix."
  }
}

variable "description" {
  description = "Description of the KMS key."
  type        = string
  default     = "Managed by OpenTofu"
}

variable "deletion_window_in_days" {
  description = "Waiting period before the key is deleted."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "allow_cloudtrail" {
  description = "Allow CloudTrail to encrypt log files with this key."
  type        = bool
  default     = false
}

variable "allow_sns_publishers" {
  description = "Allow EventBridge to publish to SNS topics encrypted with this key."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for the key."
  type        = map(string)
  default     = {}
}
