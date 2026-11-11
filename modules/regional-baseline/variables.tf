variable "is_home_region" {
  description = "True for the region that holds global resources and aggregates findings."
  type        = bool
}

variable "aggregate_regions" {
  description = "Regions linked into the home region's Security Hub aggregator."
  type        = list(string)
  default     = []
}

variable "log_bucket_name" {
  description = "Central log bucket for AWS Config."
  type        = string
}

variable "config_role_arn" {
  description = "IAM role for AWS Config."
  type        = string
}

variable "config_rules" {
  description = "Config rules deployed in every region."
  type = map(object({
    identifier       = string
    input_parameters = optional(map(string))
  }))
  default = {}
}

variable "config_global_rules" {
  description = "Config rules for global resources (IAM). Deployed only in the home region."
  type = map(object({
    identifier       = string
    input_parameters = optional(map(string))
  }))
  default = {}
}

variable "guardduty_features" {
  description = "GuardDuty protection plans."
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

variable "securityhub_standards" {
  description = "Security Hub standards to enable."
  type        = list(string)
  default     = ["aws-foundational", "cis-v3"]
}

variable "access_analyzer_name" {
  description = "Name of the IAM Access Analyzer."
  type        = string
  default     = "account-analyzer"
}

variable "restrict_default_security_groups" {
  description = "Remove all rules from default security groups in default VPCs."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for created resources."
  type        = map(string)
  default     = {}
}
