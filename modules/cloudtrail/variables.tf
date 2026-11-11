variable "name" {
  description = "Trail name. Also used for the log group and IAM role."
  type        = string
}

variable "s3_bucket_name" {
  description = "Bucket that stores the trail. Its policy must already allow CloudTrail."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key used for the log files and the CloudWatch log group."
  type        = string
}

variable "cloudwatch_log_retention_days" {
  description = "Retention of the CloudWatch log group (CIS recommends at least 365)."
  type        = number
  default     = 365
}

variable "enable_s3_data_events" {
  description = "Log S3 object-level events for all buckets. Can be costly in busy accounts."
  type        = bool
  default     = false
}

variable "enable_insights" {
  description = "Enable CloudTrail Insights (extra cost)."
  type        = bool
  default     = false
}

variable "is_organization_trail" {
  description = "Make this an organization trail. Only valid in the management or delegated admin account."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for created resources."
  type        = map(string)
  default     = {}
}
