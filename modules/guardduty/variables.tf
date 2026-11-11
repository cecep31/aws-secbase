variable "finding_publishing_frequency" {
  description = "How often updated findings are exported to EventBridge and Security Hub."
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Must be FIFTEEN_MINUTES, ONE_HOUR or SIX_HOURS."
  }
}

variable "features" {
  description = "GuardDuty protection plans to turn on or off."
  type        = map(bool)
  default = {
    S3_DATA_EVENTS         = true
    EKS_AUDIT_LOGS         = true
    EBS_MALWARE_PROTECTION = true
    RDS_LOGIN_EVENTS       = true
    LAMBDA_NETWORK_LOGS    = true
    RUNTIME_MONITORING     = false
  }
}

variable "tags" {
  description = "Tags for the detector."
  type        = map(string)
  default     = {}
}
