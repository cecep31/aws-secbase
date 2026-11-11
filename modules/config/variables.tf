variable "name" {
  description = "Name of the recorder and delivery channel."
  type        = string
  default     = "default"
}

variable "role_arn" {
  description = "IAM role used by AWS Config."
  type        = string
}

variable "s3_bucket_name" {
  description = "Bucket that receives configuration snapshots."
  type        = string
}

variable "include_global_resource_types" {
  description = "Record IAM and other global resources. Turn on in one region only to avoid duplicates."
  type        = bool
  default     = false
}

variable "snapshot_delivery_frequency" {
  description = "How often configuration snapshots are delivered."
  type        = string
  default     = "TwentyFour_Hours"

  validation {
    condition     = contains(["One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", "TwentyFour_Hours"], var.snapshot_delivery_frequency)
    error_message = "Invalid snapshot_delivery_frequency."
  }
}

variable "rules" {
  description = "AWS managed Config rules keyed by rule name."
  type = map(object({
    identifier       = string
    input_parameters = optional(map(string))
  }))
  default = {}
}

variable "tags" {
  description = "Tags for Config rules."
  type        = map(string)
  default     = {}
}
