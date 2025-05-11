variable "aws_region" {
  description = "The AWS region to deploy resources for the example."
  type        = string
  default     = "us-west-2"
}

variable "is_enabled" {
  description = "Controls whether the backend resources (S3, DynamoDB, IAM, etc.) are created."
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create for storing the Terraform state file. Must be globally unique. If not provided, a name will be auto-generated."
  type        = string
  default     = ""
}

variable "s3_encryption_type" {
  description = "The type of server-side encryption to apply to the S3 bucket. Valid values are 'SSE-S3' (default) or 'SSE-KMS'."
  type        = string
  default     = "SSE-S3"
}

variable "s3_kms_key_arn" {
  description = "The ARN of the customer-managed KMS key to use for S3 bucket encryption when 'SSE-KMS' is selected."
  type        = string
  default     = null
}

variable "s3_force_destroy" {
  description = "Whether to enable force_destroy on the S3 bucket, allowing all objects to be deleted when destroying the bucket. Should be false in production."
  type        = bool
  default     = false
}

variable "s3_versioning_enabled" {
  description = "Whether to enable versioning on the S3 bucket."
  type        = bool
  default     = true
}

variable "s3_public_access_block_enabled" {
  description = "Whether to block all public access to the S3 bucket (recommended)."
  type        = bool
  default     = true
}

variable "s3_lifecycle_enabled" {
  description = "Whether to enable lifecycle rules on the S3 bucket to transition or expire old state file versions."
  type        = bool
  default     = true
}

variable "s3_lifecycle_days_to_glacier" {
  description = "Number of days after which noncurrent object versions are transitioned to Glacier."
  type        = number
  default     = 90
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table to create for state locking. If not provided, a name will be auto-generated."
  type        = string
  default     = ""
}

variable "dynamodb_billing_mode" {
  description = "The billing mode for the DynamoDB table. Valid values are 'PAY_PER_REQUEST' or 'PROVISIONED'."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_pitr_enabled" {
  description = "Whether to enable Point-In-Time Recovery (PITR) for the DynamoDB table."
  type        = bool
  default     = true
}

variable "dynamodb_deletion_protection_enabled" {
  description = "Whether to enable deletion protection on the DynamoDB table."
  type        = bool
  default     = true
}

variable "iam_role_create" {
  description = "Whether to create a new IAM role for backend access."
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "The name of the IAM role to create for Terraform backend access. If not provided, a name will be auto-generated."
  type        = string
  default     = ""
}

variable "iam_policy_attach_inline" {
  description = "Whether to attach an inline policy granting least-privilege S3 and DynamoDB access to the IAM role."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to apply to all taggable resources created by this module."
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "tf-backend-example"
    Owner       = "example-user"
    ManagedBy   = "Terraform"
  }
}
