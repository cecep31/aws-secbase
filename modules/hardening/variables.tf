variable "access_analyzer_name" {
  description = "Name of the IAM Access Analyzer."
  type        = string
  default     = "account-analyzer"
}

variable "restrict_default_security_groups" {
  description = "Remove all rules from the default security group of default VPCs."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for created resources."
  type        = map(string)
  default     = {}
}
