locals {
  ###################################
  # Main Feature Flag & OIDC Control 🎯
  # ----------------------------------------------------
  # The is_oidc_provider_enabled flag dictates if OIDC features are active,
  # directly controlled by the module's master var.is_enabled.
  ###################################
  is_oidc_provider_enabled = var.is_enabled # OIDC functionality is active if the module is enabled.

  ###################################
  # Tags 🏷️
  # ----------------------------------------------------
  # Common tags to be applied to all resources, merging module-specific tags with user-provided tags.
  ###################################

  ###################################
  # Module Locals 🧮
  # ----------------------------------------------------
  # This section computes feature flags, normalized tags, resource names,
  # and other derived values for use throughout the module.
  ###################################

  ###################################
  # Feature Flags
  ###################################
  is_module_enabled = var.is_enabled

  is_s3_encryption_kms = var.s3_encryption_type == "SSE-KMS"
  is_s3_encryption_s3  = var.s3_encryption_type == "SSE-S3"

  is_s3_replication_enabled = var.s3_replication_enabled && var.s3_replica_bucket_arn != null && var.s3_replica_role_arn != null
  is_s3_lifecycle_enabled   = var.s3_lifecycle_enabled && var.s3_lifecycle_days_to_glacier > 0
  is_s3_logging_enabled     = var.s3_logging_enabled && var.s3_logging_bucket != null

  is_dynamodb_provisioned  = var.dynamodb_billing_mode == "PROVISIONED"
  is_dynamodb_pitr_enabled = var.dynamodb_pitr_enabled
  is_dynamodb_ttl_enabled  = var.dynamodb_ttl_enabled && var.dynamodb_ttl_attribute_name != null && var.dynamodb_ttl_attribute_name != ""

  is_iam_role_create    = var.iam_role_create
  is_iam_policy_inline  = var.iam_policy_attach_inline
  is_iam_policy_managed = var.iam_policy_attach_managed && length(var.iam_managed_policy_arns) > 0

  is_monitoring_enabled = var.monitoring_enabled && var.cloudwatch_alarm_email != null && var.cloudwatch_alarm_email != ""

  ###################################
  # Resource Names
  ###################################
  s3_bucket_name = var.bucket_name != "" ? var.bucket_name : join("-", compact([
    "tfstate",
    lookup(var.tags, "project", null),
    lookup(var.tags, "environment", null),
    data.aws_caller_identity.current.account_id
  ]))

  dynamodb_table_name = var.dynamodb_table_name != "" ? var.dynamodb_table_name : join("-", compact([
    "tfstate-lock",
    lookup(var.tags, "project", null),
    lookup(var.tags, "environment", null),
    data.aws_caller_identity.current.account_id
  ]))

  iam_role_name = var.iam_role_name != "" ? var.iam_role_name : join("-", compact([
    "tfstate-backend-role",
    lookup(var.tags, "project", null),
    lookup(var.tags, "environment", null),
    data.aws_caller_identity.current.account_id
  ]))

  ###################################
  # Tag Normalization
  ###################################
  common_tags = merge({
    "ManagedBy" = "Terraform",
    "Module"    = "tf-backend",
    "AccountId" = data.aws_caller_identity.current.account_id,
    "Region"    = data.aws_region.current.name
  }, var.tags)

  ###################################
  # S3 Encryption Block
  ###################################
  s3_encryption_block = local.is_s3_encryption_kms ? {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.s3_kms_key_arn != null ? var.s3_kms_key_arn : aws_kms_key.this[0].arn
      }
    }
    } : {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  ###################################
  # S3 Public Access Block
  ###################################
  s3_public_access_block = var.s3_public_access_block_enabled ? {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  } : null

  ###################################
  # S3 Lifecycle Rule
  ###################################
  s3_lifecycle_rule = local.is_s3_lifecycle_enabled ? [{
    id      = "archive-noncurrent-versions"
    enabled = true
    noncurrent_version_transitions = [{
      days          = var.s3_lifecycle_days_to_glacier
      storage_class = "GLACIER"
    }]
  }] : []

  ###################################
  # S3 Logging Block
  ###################################
  s3_logging_block = local.is_s3_logging_enabled ? {
    target_bucket = var.s3_logging_bucket
    target_prefix = var.s3_logging_prefix != null ? var.s3_logging_prefix : "tfstate-logs/"
  } : null

  ###################################
  # S3 Replication Block
  ###################################
  s3_replication_block = local.is_s3_replication_enabled ? [{
    role = var.s3_replica_role_arn
    rules = [{
      id     = "replicate-tfstate"
      status = "Enabled"
      destination = {
        bucket        = var.s3_replica_bucket_arn
        storage_class = "STANDARD"
      }
      delete_marker_replication = {
        status = "Disabled"
      }
    }]
  }] : []

  ###################################
  # DynamoDB TTL Block
  ###################################
  dynamodb_ttl_block = local.is_dynamodb_ttl_enabled ? {
    enabled        = true
    attribute_name = var.dynamodb_ttl_attribute_name
  } : null

  ###################################
  # IAM Trust Principals
  ###################################
  iam_trust_principals = length(var.iam_trust_principals) > 0 ? var.iam_trust_principals : [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)]

  ###################################
  # Feature Flags Output
  ###################################
  feature_flags = {
    is_module_enabled         = local.is_module_enabled
    is_s3_encryption_kms      = local.is_s3_encryption_kms
    is_s3_replication_enabled = local.is_s3_replication_enabled
    is_s3_lifecycle_enabled   = local.is_s3_lifecycle_enabled
    is_s3_logging_enabled     = local.is_s3_logging_enabled
    is_dynamodb_provisioned   = local.is_dynamodb_provisioned
    is_dynamodb_pitr_enabled  = local.is_dynamodb_pitr_enabled
    is_dynamodb_ttl_enabled   = local.is_dynamodb_ttl_enabled
    is_iam_role_create        = local.is_iam_role_create
    is_iam_policy_inline      = local.is_iam_policy_inline
    is_iam_policy_managed     = local.is_iam_policy_managed
    is_monitoring_enabled     = local.is_monitoring_enabled
  }
}
