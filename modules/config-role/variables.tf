variable "name" {
  description = "Name of the IAM role used by AWS Config in every region."
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the bucket that receives Config snapshots."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key that encrypts the log bucket."
  type        = string
}

variable "tags" {
  description = "Tags for the role."
  type        = map(string)
  default     = {}
}
