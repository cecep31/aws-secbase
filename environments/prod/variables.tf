variable "project" {
  description = "Short project name used in resource names."
  type        = string
  default     = "secbase"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,16}$", var.project))
    error_message = "project must be 2-16 chars of lowercase letters, numbers or hyphens."
  }
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "home_region" {
  description = "Region for global resources (CloudTrail, buckets, alerts, Security Hub aggregation)."
  type        = string
  default     = "ap-southeast-1"
}

variable "additional_regions" {
  description = "Other regions that get GuardDuty, Security Hub, Config and regional hardening."
  type        = list(string)
  default     = []
}

variable "regions_pending_removal" {
  description = "Regions being retired. Their baseline is destroyed but the provider is kept for one apply."
  type        = list(string)
  default     = []
}

variable "state_kms_key_id" {
  description = "KMS key ARN for OpenTofu state encryption (output state_kms_key_arn from bootstrap)."
  type        = string
}

variable "alert_emails" {
  description = "Email addresses that receive security alerts."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Days to keep CloudTrail and Config logs in S3. 0 keeps them forever."
  type        = number
  default     = 2555 # ~7 years
}

variable "log_transition_days" {
  description = "Days before logs move to Glacier Instant Retrieval."
  type        = number
  default     = 90
}

variable "access_log_retention_days" {
  description = "Days to keep S3 server access logs."
  type        = number
  default     = 365
}

variable "cloudtrail_log_group_retention_days" {
  description = "Retention of the CloudTrail CloudWatch log group."
  type        = number
  default     = 365
}

variable "cloudtrail_s3_data_events" {
  description = "Log S3 object-level events (extra cost)."
  type        = bool
  default     = false
}

variable "guardduty_features" {
  description = "GuardDuty protection plans."
  type        = map(bool)
  default = {
    S3_DATA_EVENTS         = true
    EKS_AUDIT_LOGS         = true
    EBS_MALWARE_PROTECTION = true
    RDS_LOGIN_EVENTS       = true
    LAMBDA_NETWORK_LOGS    = true
    RUNTIME_MONITORING     = false
  }
}

variable "securityhub_standards" {
  description = "Security Hub standards: aws-foundational, cis-v3, cis-v1.4, nist-800-53, pci-dss."
  type        = list(string)
  default     = ["aws-foundational", "cis-v3"]
}

variable "securityhub_alert_severities" {
  description = "Security Hub severities that send an alert."
  type        = list(string)
  default     = ["CRITICAL", "HIGH"]
}

variable "config_rules" {
  description = "AWS managed Config rules deployed in every region."
  type = map(object({
    identifier       = string
    input_parameters = optional(map(string))
  }))
  default = {
    s3-bucket-public-read-prohibited  = { identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED" }
    s3-bucket-public-write-prohibited = { identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED" }
    s3-bucket-ssl-requests-only       = { identifier = "S3_BUCKET_SSL_REQUESTS_ONLY" }
    encrypted-volumes                 = { identifier = "ENCRYPTED_VOLUMES" }
    ec2-ebs-encryption-by-default     = { identifier = "EC2_EBS_ENCRYPTION_BY_DEFAULT" }
    ec2-imdsv2-check                  = { identifier = "EC2_IMDSV2_CHECK" }
    restricted-ssh                    = { identifier = "INCOMING_SSH_DISABLED" }
    rds-storage-encrypted             = { identifier = "RDS_STORAGE_ENCRYPTED" }
    rds-instance-public-access-check  = { identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK" }
    vpc-flow-logs-enabled             = { identifier = "VPC_FLOW_LOGS_ENABLED" }
    guardduty-enabled-centralized     = { identifier = "GUARDDUTY_ENABLED_CENTRALIZED" }
  }
}

variable "config_global_rules" {
  description = "Config rules for IAM and other global resources, deployed in the home region only."
  type = map(object({
    identifier       = string
    input_parameters = optional(map(string))
  }))
  default = {
    root-account-mfa-enabled                   = { identifier = "ROOT_ACCOUNT_MFA_ENABLED" }
    iam-root-access-key-check                  = { identifier = "IAM_ROOT_ACCESS_KEY_CHECK" }
    iam-user-mfa-enabled                       = { identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS" }
    iam-password-policy                        = { identifier = "IAM_PASSWORD_POLICY" }
    iam-user-unused-credentials-check          = { identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK", input_parameters = { maxCredentialUsageAge = "45" } }
    access-keys-rotated                        = { identifier = "ACCESS_KEYS_ROTATED", input_parameters = { maxAccessKeyAge = "90" } }
    iam-policy-no-statements-with-admin-access = { identifier = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS" }
    cloudtrail-enabled                         = { identifier = "CLOUD_TRAIL_ENABLED" }
    cloudtrail-log-file-validation             = { identifier = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED" }
    cloudtrail-encryption-enabled              = { identifier = "CLOUD_TRAIL_ENCRYPTION_ENABLED" }
    multi-region-cloudtrail-enabled            = { identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED" }
  }
}

variable "tags" {
  description = "Extra tags applied to every resource."
  type        = map(string)
  default     = {}
}
