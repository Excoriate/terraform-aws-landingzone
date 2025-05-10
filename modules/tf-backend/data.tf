###################################
# Data Sources 📊
# ----------------------------------------------------
#
# Data sources required by this module
#
###################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Optionally, lookup KMS key if s3_kms_key_arn is provided (for validation or reference)
# data "aws_kms_key" "s3" {
#   count = local.is_s3_encryption_kms && var.s3_kms_key_arn != null ? 1 : 0
#   key_id = var.s3_kms_key_arn
# }
