variable "project" {
  description = "Short project name used in resource names."
  type        = string
  default     = "secbase"
}

variable "region" {
  description = "Region for the state bucket and key."
  type        = string
  default     = "ap-southeast-1"
}

variable "allowed_account_ids" {
  description = "Optional guard: AWS account IDs this configuration may run against. Empty allows any account."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for id in var.allowed_account_ids : can(regex("^[0-9]{12}$", id))])
    error_message = "Each account ID must be exactly 12 digits (use quotes to keep leading zeros)."
  }
}
