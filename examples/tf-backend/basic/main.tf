
module "this" {
  source = "../../../modules/tf-backend"

  is_enabled                           = var.is_enabled
  bucket_name                          = var.bucket_name
  s3_encryption_type                   = var.s3_encryption_type
  s3_kms_key_arn                       = var.s3_kms_key_arn
  s3_force_destroy                     = var.s3_force_destroy
  s3_versioning_enabled                = var.s3_versioning_enabled
  s3_public_access_block_enabled       = var.s3_public_access_block_enabled
  s3_lifecycle_enabled                 = var.s3_lifecycle_enabled
  s3_lifecycle_days_to_glacier         = var.s3_lifecycle_days_to_glacier
  dynamodb_table_name                  = var.dynamodb_table_name
  dynamodb_billing_mode                = var.dynamodb_billing_mode
  dynamodb_pitr_enabled                = var.dynamodb_pitr_enabled
  dynamodb_deletion_protection_enabled = var.dynamodb_deletion_protection_enabled
  iam_role_create                      = var.iam_role_create
  iam_role_name                        = var.iam_role_name
  iam_policy_attach_inline             = var.iam_policy_attach_inline
  tags                                 = var.tags
}
