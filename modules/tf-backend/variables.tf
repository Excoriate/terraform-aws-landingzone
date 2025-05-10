###################################
# Module Variables 📝
# ----------------------------------------------------
#
# This section defines the variables that can be customized when
# using this module. Each variable includes a description of its
# purpose and any validation rules that apply.
#
###################################

###################################
# Module Feature Flags 🎯
###################################
variable "is_enabled" {
  description = <<-DESC
  Controls whether the backend resources (S3, DynamoDB, IAM, etc.) are created.
  Setting this to `false` will prevent any resources in this module from being created.
  This is the primary feature flag for the entire module.
  DESC
  type        = bool
  default     = true
}

###################################
# S3 Bucket Configuration
###################################
variable "bucket_name" {
  description = <<-DESC
  The name of the S3 bucket to create for storing the Terraform state file. Must be globally unique. If not provided, a name will be auto-generated based on the project and environment.
  DESC
  type        = string
  default     = ""
}

variable "s3_encryption_type" {
  description = <<-DESC
  The type of server-side encryption to apply to the S3 bucket. Valid values are "SSE-S3" (default) or "SSE-KMS". If "SSE-KMS" is selected, you may specify a customer-managed KMS key via `s3_kms_key_arn`.
  DESC
  type        = string
  default     = "SSE-S3"
  validation {
    condition     = contains(["SSE-S3", "SSE-KMS"], var.s3_encryption_type)
    error_message = "s3_encryption_type must be either 'SSE-S3' or 'SSE-KMS'."
  }
}

variable "s3_kms_key_arn" {
  description = <<-DESC
  The ARN of the customer-managed KMS key to use for S3 bucket encryption when `s3_encryption_type` is "SSE-KMS". If not set and SSE-KMS is selected, a new KMS key will be created.
  DESC
  type        = string
  default     = null
}

variable "s3_force_destroy" {
  description = <<-DESC
  Whether to enable force_destroy on the S3 bucket, allowing all objects (including noncurrent versions) to be deleted when destroying the bucket. Should be `false` in production for safety.
  DESC
  type        = bool
  default     = false
}

variable "s3_versioning_enabled" {
  description = <<-DESC
  Whether to enable versioning on the S3 bucket. Versioning allows recovery from accidental deletions or corruption of the state file.
  DESC
  type        = bool
  default     = true
}

variable "s3_public_access_block_enabled" {
  description = <<-DESC
  Whether to block all public access to the S3 bucket (recommended). This enables all four public access block settings.
  DESC
  type        = bool
  default     = true
}

variable "s3_replication_enabled" {
  description = <<-DESC
  Whether to enable cross-region or cross-account replication for the S3 bucket. If enabled, you must provide `s3_replica_bucket_arn` and `s3_replica_role_arn`.
  DESC
  type        = bool
  default     = false
}

variable "s3_replica_bucket_arn" {
  description = <<-DESC
  The ARN of the destination S3 bucket for replication. Required if `s3_replication_enabled` is true.
  DESC
  type        = string
  default     = null
}

variable "s3_replica_role_arn" {
  description = <<-DESC
  The ARN of the IAM role to use for S3 replication. Required if `s3_replication_enabled` is true.
  DESC
  type        = string
  default     = null
}

variable "s3_lifecycle_enabled" {
  description = <<-DESC
  Whether to enable lifecycle rules on the S3 bucket to transition or expire old state file versions (e.g., archive to Glacier after 90 days).
  DESC
  type        = bool
  default     = true
}

variable "s3_lifecycle_days_to_glacier" {
  description = <<-DESC
  Number of days after which noncurrent object versions are transitioned to Glacier. Only used if `s3_lifecycle_enabled` is true.
  DESC
  type        = number
  default     = 90
}

variable "s3_logging_enabled" {
  description = <<-DESC
  Whether to enable server-access logging for the S3 bucket. If enabled, you must provide `s3_logging_bucket` and optionally `s3_logging_prefix`.
  DESC
  type        = bool
  default     = false
}

variable "s3_logging_bucket" {
  description = <<-DESC
  The name of the S3 bucket where server-access logs will be delivered. Required if `s3_logging_enabled` is true.
  DESC
  type        = string
  default     = null
}

variable "s3_logging_prefix" {
  description = <<-DESC
  The prefix for S3 server-access logs. Optional.
  DESC
  type        = string
  default     = null
}

###################################
# DynamoDB Table Configuration
###################################
variable "dynamodb_table_name" {
  description = <<-DESC
  The name of the DynamoDB table to create for state locking. If not provided, a name will be auto-generated based on the project and environment.
  DESC
  type        = string
  default     = ""
}

variable "dynamodb_billing_mode" {
  description = <<-DESC
  The billing mode for the DynamoDB table. Valid values are "PAY_PER_REQUEST" (on-demand) or "PROVISIONED". If "PROVISIONED", you must specify `dynamodb_read_capacity` and `dynamodb_write_capacity`.
  DESC
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.dynamodb_billing_mode)
    error_message = "dynamodb_billing_mode must be either 'PAY_PER_REQUEST' or 'PROVISIONED'."
  }
}

variable "dynamodb_read_capacity" {
  description = <<-DESC
  The read capacity units for the DynamoDB table (only used if billing mode is PROVISIONED).
  DESC
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = <<-DESC
  The write capacity units for the DynamoDB table (only used if billing mode is PROVISIONED).
  DESC
  type        = number
  default     = 5
}

variable "dynamodb_pitr_enabled" {
  description = <<-DESC
  Whether to enable Point-In-Time Recovery (PITR) for the DynamoDB table, allowing restoration to any point within the retention window.
  DESC
  type        = bool
  default     = true
}

variable "dynamodb_deletion_protection_enabled" {
  description = <<-DESC
  Whether to enable deletion protection on the DynamoDB table to prevent accidental deletion.
  DESC
  type        = bool
  default     = true
}

variable "dynamodb_ttl_enabled" {
  description = <<-DESC
  Whether to enable TTL (Time To Live) on the DynamoDB table. If enabled, you must specify `dynamodb_ttl_attribute_name`.
  DESC
  type        = bool
  default     = false
}

variable "dynamodb_ttl_attribute_name" {
  description = <<-DESC
  The name of the attribute to use for TTL on the DynamoDB table. Required if `dynamodb_ttl_enabled` is true.
  DESC
  type        = string
  default     = null
}

###################################
# IAM Role and Policy Management
###################################
variable "iam_role_name" {
  description = <<-DESC
  The name of the IAM role to create for Terraform backend access. If not provided, a name will be auto-generated. If you wish to use an existing role, set `iam_role_create` to false and provide `iam_role_arn`.
  DESC
  type        = string
  default     = ""
}

variable "iam_role_create" {
  description = <<-DESC
  Whether to create a new IAM role for backend access. If false, you must provide `iam_role_arn`.
  DESC
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = <<-DESC
  The ARN of an existing IAM role to use for backend access. Required if `iam_role_create` is false.
  DESC
  type        = string
  default     = null
}

variable "iam_policy_attach_inline" {
  description = <<-DESC
  Whether to attach an inline policy granting least-privilege S3 and DynamoDB access to the IAM role.
  DESC
  type        = bool
  default     = true
}

variable "iam_policy_attach_managed" {
  description = <<-DESC
  Whether to attach managed policies to the IAM role. If true, you must provide `iam_managed_policy_arns`.
  DESC
  type        = bool
  default     = false
}

variable "iam_managed_policy_arns" {
  description = <<-DESC
  List of managed policy ARNs to attach to the IAM role. Only used if `iam_policy_attach_managed` is true.
  DESC
  type        = list(string)
  default     = []
}

variable "iam_trust_principals" {
  description = <<-DESC
  List of AWS principals (ARNs) that can assume the IAM role. Supports cross-account/region access. If not set, defaults to the current account root.
  DESC
  type        = list(string)
  default     = []
}

variable "arn_format" {
  description = <<-DESC
  The ARN format to use for resources. Useful for AWS GovCloud or China regions. Valid values: "standard", "aws-cn", "aws-us-gov".
  DESC
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "aws-cn", "aws-us-gov"], var.arn_format)
    error_message = "arn_format must be one of 'standard', 'aws-cn', or 'aws-us-gov'."
  }
}

###################################
# Tagging and Metadata
###################################
variable "tags" {
  description = <<-DESC
  A map of tags to apply to all taggable resources created by this module. Tags are key-value pairs for resource management, billing, and compliance. Recommended keys: Environment, Project, Owner, CostCenter.
  DESC
  type        = map(string)
  default     = {}
  validation {
    condition     = can([for k, v in var.tags : regex("^[a-zA-Z0-9_-]+$", k)])
    error_message = "Tag keys must be alphanumeric with optional underscores or hyphens."
  }
}

###################################
# Monitoring and Alerts
###################################
variable "monitoring_enabled" {
  description = <<-DESC
  Whether to enable CloudWatch monitoring and alarms for S3 and DynamoDB resources.
  DESC
  type        = bool
  default     = false
}

variable "cloudwatch_alarm_email" {
  description = <<-DESC
  The email address to notify for CloudWatch alarms. Required if `monitoring_enabled` is true.
  DESC
  type        = string
  default     = null
}

