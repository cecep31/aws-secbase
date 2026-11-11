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

variable "state_passphrase" {
  description = "Passphrase that encrypts the local bootstrap state. At least 16 characters."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.state_passphrase) >= 16
    error_message = "state_passphrase must be at least 16 characters."
  }
}
