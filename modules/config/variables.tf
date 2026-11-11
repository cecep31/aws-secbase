variable "role_name" {
  description = "Name of the IAM role used by AWS Config."
  type        = string
}

variable "s3_bucket_name" {
  description = "Bucket that receives configuration snapshots."
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of that bucket."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key that encrypts the bucket."
  type        = string
}

variable "tags" {
  description = "Tags for created resources."
  type        = map(string)
  default     = {}
}
