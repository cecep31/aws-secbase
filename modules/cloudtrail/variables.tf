variable "name" {
  description = "Trail name."
  type        = string
}

variable "s3_bucket_name" {
  description = "Bucket that stores the trail. Its policy must already allow CloudTrail."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key used to encrypt the log files."
  type        = string
}

variable "tags" {
  description = "Tags for the trail."
  type        = map(string)
  default     = {}
}
