# Default fixture for the tf-backend basic example.
# This enables the module instance with production-grade, secure defaults.

# Enable the tf-backend module:
# Provision a remote backend using S3 for state storage and DynamoDB for state locking.
is_enabled = true

# S3 bucket name must be globally unique.
# Uncomment and set to override the auto-generated name based on project and account.
# bucket_name = "my-unique-tf-backend-bucket-123456"

# Server-side encryption configuration:
# Default is SSE-S3 (AES256). To use SSE-KMS, uncomment and set below:
# s3_encryption_type = "SSE-KMS"
# s3_kms_key_arn    = "arn:aws:kms:us-west-2:123456789012:key/abcd-1234-efgh-5678"

# Force destroy controls whether the S3 bucket and all versions are deleted when destroying.
# false -> retains all objects for safety in production.
s3_force_destroy = false

# Enable versioning on the S3 bucket to protect state file against accidental deletion or corruption.
s3_versioning_enabled = true

# Block all public access to the S3 bucket for compliance and security.
s3_public_access_block_enabled = true

# Enable lifecycle rules on the S3 bucket to transition noncurrent versions to Glacier for cost optimization.
s3_lifecycle_enabled = true

# Days after which noncurrent object versions transition to Glacier storage (pocket cost optimization).
s3_lifecycle_days_to_glacier = 90

# DynamoDB billing mode for the lock table:
# "PAY_PER_REQUEST" -> on-demand, no capacity planning required.
dynamodb_billing_mode = "PAY_PER_REQUEST"

# Enable Point-In-Time Recovery (PITR) on the DynamoDB table for restore capabilities.
dynamodb_pitr_enabled = true

# Enable deletion protection to prevent accidental deletion of the DynamoDB lock table.
dynamodb_deletion_protection_enabled = true

# IAM Role creation flag:
# true -> create a new IAM role for backend access; false -> use existing IAM role ARN.
iam_role_create = true

# Attach an inline policy granting least-privilege S3 and DynamoDB access to the IAM role.
iam_policy_attach_inline = true

# Tags applied uniformly to all created resources for environment, project, owner, and management tracking.
tags = {
  Environment = "production"         # Target deployment environment
  Project     = "tf-backend-example" # Project identifier
  Owner       = "example-user"       # Resource owner or team
  ManagedBy   = "Terraform"          # Tool managing these resources
}

# Optional: Enable server-access logging for auditing S3 access.
# s3_logging_enabled    = true            # Enable server-access logs for the S3 bucket.
# s3_logging_bucket     = "my-log-bucket"      # S3 bucket to store access logs.
# s3_logging_prefix     = "logs/tfstate/"       # Prefix for log objects.

# Optional: Enable cross-region replication for disaster recovery.
# s3_replication_enabled = true            # Replicate state objects to another region/bucket.
# s3_replica_bucket_arn  = "arn:aws:s3:::my-replica-bucket" # Destination bucket ARN.
# s3_replica_role_arn    = "arn:aws:iam::123456789012:role/replication-role" # IAM role for replication.

# Optional: Enable TTL on the DynamoDB lock table to auto-expire stale locks.
# dynamodb_ttl_enabled        = true    # Automatically expire old lock items.
# dynamodb_ttl_attribute_name = "ExpiresAt"  # Attribute name used for TTL.

# Optional: Enable CloudWatch monitoring and alarms for proactive alerting.
# monitoring_enabled         = true        # Enable CloudWatch metrics and alarms.
# cloudwatch_alarm_email     = "alerts@example.com"  # Email address for alarm notifications.

# Optional: Attach additional managed IAM policies for extended permissions.
# iam_policy_attach_managed   = true
# iam_managed_policy_arns     = [
#   "arn:aws:iam::aws:policy/AmazonS3FullAccess"  # Example managed policy ARN.
# ]
