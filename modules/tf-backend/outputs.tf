###################################
# Module-Specific Outputs 🚀
# ----------------------------------------------------
#
# These outputs are specific to the functionality provided by this module.
# They offer insights and access points into the resources created or managed by this module.
#
###################################
output "is_enabled" {
  value       = var.is_enabled
  description = "Indicates whether the OIDC module and its resources are enabled."
}

###################################
# Module Outputs 📤
# ----------------------------------------------------
#
# This section defines the outputs that will be made available
# to other Terraform configurations that use this module.
#
###################################

###################################
# Module Outputs 🚀
# ----------------------------------------------------
# These outputs provide access to the key resources and configuration
# details created or managed by this module. All outputs are documented
# for clarity and composability.
###################################

output "s3_bucket_id" {
  value       = try(aws_s3_bucket.this[0].id, null)
  description = "The name (ID) of the S3 bucket used for Terraform state storage."
}

output "s3_bucket_arn" {
  value       = try(aws_s3_bucket.this[0].arn, null)
  description = "The ARN of the S3 bucket used for Terraform state storage."
}

output "s3_bucket_region" {
  value       = try(aws_s3_bucket.this[0].region, null)
  description = "The AWS region where the S3 bucket is created."
}

output "dynamodb_table_id" {
  value       = try(aws_dynamodb_table.this[0].id, null)
  description = "The name (ID) of the DynamoDB table used for state locking."
}

output "dynamodb_table_arn" {
  value       = try(aws_dynamodb_table.this[0].arn, null)
  description = "The ARN of the DynamoDB table used for state locking."
}

output "iam_role_arn" {
  value       = try(local.is_iam_role_create ? aws_iam_role.this[0].arn : var.iam_role_arn, null)
  description = "The ARN of the IAM role to be assumed for backend access."
}

output "feature_flags" {
  value       = local.feature_flags
  description = "A map of feature flags indicating the status of various module functionalities."
}

output "tags_set" {
  value       = local.common_tags
  description = "The final set of tags applied to resources by this module."
}

output "monitoring_enabled" {
  value       = local.is_monitoring_enabled
  description = "Indicates whether CloudWatch monitoring and alarms are enabled for S3 and DynamoDB resources."
}
