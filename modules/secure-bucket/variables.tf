variable "bucket_name" {
  description = "Globally unique bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 chars of lowercase letters, numbers, dots or hyphens."
  }
}

variable "kms_key_arn" {
  description = "KMS key for SSE-KMS. Null uses SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "policy_documents" {
  description = "Extra IAM policy JSON documents merged into the bucket policy."
  type        = list(string)
  default     = []
}

variable "transition_to_glacier_ir_days" {
  description = "Days before objects move to Glacier Instant Retrieval. 0 disables."
  type        = number
  default     = 90
}

variable "expiration_days" {
  description = "Days before current objects expire. 0 keeps them forever."
  type        = number
  default     = 365

  validation {
    condition     = var.expiration_days == 0 || var.transition_to_glacier_ir_days == 0 || var.expiration_days > var.transition_to_glacier_ir_days
    error_message = "expiration_days must be greater than transition_to_glacier_ir_days."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Days before noncurrent object versions are removed."
  type        = number
  default     = 90
}

variable "force_destroy" {
  description = "Allow destroying the bucket even when it holds objects. Keep false for log and state buckets."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for the bucket."
  type        = map(string)
  default     = {}
}
