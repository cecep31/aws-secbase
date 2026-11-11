variable "access_analyzer_name" {
  description = "Name of the IAM Access Analyzer."
  type        = string
  default     = "account-analyzer"
}

variable "imds_hop_limit" {
  description = "IMDS PUT response hop limit. 2 lets containers on the instance reach IMDSv2."
  type        = number
  default     = 2
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
