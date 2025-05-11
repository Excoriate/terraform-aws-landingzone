###################################
# Module Resources 🛠️
# ----------------------------------------------------
#
# This section declares the resources that will be created or managed by this Terraform module.
# Each resource is annotated with comments explaining its purpose and any notable configurations.
#
###################################
resource "aws_s3_bucket" "this" {
  count         = local.is_module_enabled ? 1 : 0
  bucket        = local.s3_bucket_name
  force_destroy = var.s3_force_destroy
  tags          = local.common_tags
}

resource "aws_s3_bucket_versioning" "this" {
  count  = local.is_module_enabled && var.s3_versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = local.is_module_enabled ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  dynamic "rule" {
    for_each = [local.s3_encryption_block.rule]
    content {
      apply_server_side_encryption_by_default {
        sse_algorithm     = rule.value.apply_server_side_encryption_by_default.sse_algorithm
        kms_master_key_id = try(rule.value.apply_server_side_encryption_by_default.kms_master_key_id, null)
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count                   = local.is_module_enabled && var.s3_public_access_block_enabled ? 1 : 0
  bucket                  = aws_s3_bucket.this[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = local.is_module_enabled && local.is_s3_lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  dynamic "rule" {
    for_each = local.s3_lifecycle_rule
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"
      filter {
        prefix = ""
      }
      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count         = local.is_module_enabled && local.is_s3_logging_enabled ? 1 : 0
  bucket        = aws_s3_bucket.this[0].id
  target_bucket = var.s3_logging_bucket
  target_prefix = var.s3_logging_prefix != null ? var.s3_logging_prefix : "tfstate-logs/"
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count  = local.is_module_enabled && local.is_s3_replication_enabled ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  role   = var.s3_replica_role_arn
  dynamic "rule" {
    for_each = local.s3_replication_block[0].rules
    content {
      id     = rule.value.id
      status = rule.value.status
      destination {
        bucket        = rule.value.destination.bucket
        storage_class = rule.value.destination.storage_class
      }
      delete_marker_replication {
        status = rule.value.delete_marker_replication.status
      }
    }
  }
  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_policy" "encryption_enforcement" {
  count  = local.is_module_enabled ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnEncryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.this[0].arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = local.is_s3_encryption_kms ? "aws:kms" : "AES256"
          }
        }
      }
    ]
  })
}

###################################
# KMS Key (if SSE-KMS and no key provided)
###################################
resource "aws_kms_key" "this" {
  count                   = local.is_module_enabled && local.is_s3_encryption_kms && var.s3_kms_key_arn == null ? 1 : 0
  description             = "KMS key for Terraform state S3 bucket encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.common_tags
}

###################################
# DynamoDB Table for State Locking
###################################
resource "aws_dynamodb_table" "this" {
  count          = local.is_module_enabled ? 1 : 0
  name           = local.dynamodb_table_name
  billing_mode   = var.dynamodb_billing_mode
  hash_key       = "LockID"
  read_capacity  = local.is_dynamodb_provisioned ? var.dynamodb_read_capacity : null
  write_capacity = local.is_dynamodb_provisioned ? var.dynamodb_write_capacity : null
  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery {
    enabled = var.dynamodb_pitr_enabled
  }
  deletion_protection_enabled = var.dynamodb_deletion_protection_enabled
  dynamic "ttl" {
    for_each = local.is_dynamodb_ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.dynamodb_ttl_attribute_name
    }
  }
  tags = local.common_tags
}

###################################
# IAM Role and Policy for Backend Access
###################################
resource "aws_iam_role" "this" {
  count = local.is_module_enabled && local.is_iam_role_create ? 1 : 0
  name  = local.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = local.iam_trust_principals
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy" "inline" {
  count = local.is_module_enabled && local.is_iam_role_create && local.is_iam_policy_inline ? 1 : 0
  name  = "tf-backend-inline-policy"
  role  = aws_iam_role.this[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.this[0].arn,
          "${aws_s3_bucket.this[0].arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          aws_dynamodb_table.this[0].arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "managed" {
  count      = local.is_module_enabled && local.is_iam_role_create && local.is_iam_policy_managed ? length(var.iam_managed_policy_arns) : 0
  role       = aws_iam_role.this[0].id
  policy_arn = var.iam_managed_policy_arns[count.index]
}
