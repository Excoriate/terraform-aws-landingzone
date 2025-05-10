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

output "tags_set" {
  value       = local.common_tags # Use the processed common_tags from locals
  description = "The final set of tags applied to resources by this module."
}

output "feature_flags" {
  value = {
    is_oidc_provider_enabled = local.is_oidc_provider_enabled
    # Add other relevant feature flags from locals if they existed, for now, it is mainly this one.
  }
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
  value       = local.is_oidc_provider_enabled ? local.effective_oidc_provider_arn : null
}

output "oidc_roles" {
  description = "A map of the created IAM roles, where keys are role names and values are objects containing role ARN, ID, and name."
  value = local.is_oidc_provider_enabled ? {
    for role_name, role_obj in aws_iam_role.oidc : role_name => {
      arn  = role_obj.arn
      id   = role_obj.id
      name = role_obj.name
    }
  } : {}
}

output "oidc_role_arns" {
  description = "A map of the created IAM role ARNs, where keys are role names."
  value = local.is_oidc_provider_enabled ? {
    for role_name, role_obj in aws_iam_role.oidc : role_name => role_obj.arn
  } : {}
  sensitive = true # Role ARNs can be sensitive.
}
