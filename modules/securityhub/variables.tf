variable "standards" {
  description = "Security standards to enable."
  type        = list(string)
  default     = ["aws-foundational", "cis-v3"]

  validation {
    condition     = alltrue([for s in var.standards : contains(["aws-foundational", "cis-v3", "cis-v1.4", "nist-800-53", "pci-dss"], s)])
    error_message = "Valid values: aws-foundational, cis-v3, cis-v1.4, nist-800-53, pci-dss."
  }
}

variable "aggregate_regions" {
  description = "Regions whose findings are aggregated into this region. Empty disables aggregation."
  type        = list(string)
  default     = []
}
