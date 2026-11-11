variable "password_policy" {
  description = "IAM password policy settings (CIS 1.8 / 1.9)."
  type = object({
    minimum_length   = optional(number, 14)
    max_age_days     = optional(number, 90)
    reuse_prevention = optional(number, 24)
  })
  default = {}

  validation {
    condition     = var.password_policy.minimum_length >= 14
    error_message = "CIS requires a minimum password length of at least 14."
  }
}
