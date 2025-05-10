###################################
# Module-Specific Outputs 🚀
# ----------------------------------------------------
#
# These outputs are specific to the functionality provided by this module.
# They offer insights and access points into the resources created or managed by this module.
#
###################################
output "is_enabled" {
  value       = module.main.is_enabled
  description = "Indicates whether the OIDC module and its resources are enabled."
}

output "tags" {
  value       = module.main.tags_set # Use the processed common_tags from locals
  description = "The final set of tags applied to resources by this module."
}

output "feature_flags" {
  value       = module.main.feature_flags
  description = "A map of feature flags indicating the status of various module functionalities."
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
# OIDC Outputs 🔑
# ----------------------------------------------------
#
# Outputs for the IAM OIDC Provider and Roles
#
###################################

output "oidc_provider_arn" {
  description = "The ARN of the IAM OIDC provider. This will be the ARN of the newly created provider or the existing one if `oidc_use_existing_provider` was true."
  value       = module.main.oidc_provider_arn
}

output "oidc_roles" {
  description = "A map of the created IAM roles, where keys are role names and values are objects containing role ARN, ID, and name."
  value       = module.main.oidc_roles
}

output "oidc_role_arns" {
  description = "A map of the created IAM role ARNs, where keys are role names."
  value       = module.main.oidc_role_arns
  sensitive   = true # Role ARNs can be sensitive.
}
