###################################
# Module-Specific Outputs 🚀
# ----------------------------------------------------
#
# These outputs are specific to the functionality provided by this module.
# They offer insights and access points into the resources created or managed by this module.
#
###################################
output "is_enabled" {
  value       = module.this.is_enabled
  description = "Indicates whether the backend module and its resources are enabled."
}

output "s3_bucket_id" {
  value       = module.this.s3_bucket_id
  description = "The name (ID) of the S3 bucket used for Terraform state storage."
}

output "s3_bucket_arn" {
  value       = module.this.s3_bucket_arn
  description = "The ARN of the S3 bucket used for Terraform state storage."
}

output "dynamodb_table_id" {
  value       = module.this.dynamodb_table_id
  description = "The name (ID) of the DynamoDB table used for state locking."
}

output "dynamodb_table_arn" {
  value       = module.this.dynamodb_table_arn
  description = "The ARN of the DynamoDB table used for state locking."
}

output "iam_role_arn" {
  value       = module.this.iam_role_arn
  description = "The ARN of the IAM role to be assumed for backend access."
}

output "feature_flags" {
  value       = module.this.feature_flags
  description = "A map of feature flags indicating the status of various module functionalities."
}

output "tags_set" {
  value       = module.this.tags_set
  description = "The final set of tags applied to resources by this module."
}

output "monitoring_enabled" {
  value       = module.this.monitoring_enabled
  description = "Indicates whether CloudWatch monitoring and alarms are enabled for S3 and DynamoDB resources."
}
