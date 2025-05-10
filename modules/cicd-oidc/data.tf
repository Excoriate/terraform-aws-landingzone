###################################
# Data Sources 📊
# ----------------------------------------------------
#
# Data sources required by this module
#
###################################

data "aws_caller_identity" "current" {}

###################################
# OIDC Data Sources 🔑
# ----------------------------------------------------
#
# Data sources for OIDC provider configuration
#
###################################

# Fetches the OIDC provider's server certificate to extract the thumbprint if not provided.
# This is only attempted if a new provider is being created and thumbprints are not supplied.
data "tls_certificate" "oidc" {
  count = local.is_oidc_provider_enabled && !var.oidc_use_existing_provider && length(var.oidc_thumbprint_list) == 0 ? 1 : 0

  url = var.oidc_provider_url
}

# Looks up an existing IAM OIDC provider if oidc_use_existing_provider is true.
data "aws_iam_openid_connect_provider" "existing" {
  count = local.is_oidc_provider_enabled && var.oidc_use_existing_provider ? 1 : 0

  url = var.oidc_provider_url # Use the same URL to look up the existing provider.
}

# Construct the Assume Role Policy Document for each OIDC Role
data "aws_iam_policy_document" "oidc_assume_role" {
  # Create one policy document per role defined in var.oidc_roles, only if OIDC is enabled
  for_each = local.is_oidc_provider_enabled ? { for role in var.oidc_roles : role.name => role } : {}

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type = "Federated"
      # Reference the OIDC provider ARN (either created or existing) via the local variable
      identifiers = [local.effective_oidc_provider_arn]
    }

    # Dynamically add condition blocks based on the assume_role_conditions list for the specific role
    dynamic "condition" {
      for_each = try(each.value.assume_role_conditions, [])
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}
