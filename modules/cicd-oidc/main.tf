###################################
# Module Resources 🛠️
# ----------------------------------------------------
#
# This section declares the resources that will be created or managed by this Terraform module.
# Each resource is annotated with comments explaining its purpose and any notable configurations.
#
###################################

###################################
# OIDC Provider and Roles 🔑
# ----------------------------------------------------
#
# Creates an IAM OIDC provider and associated roles
# for federated access from CI/CD systems like
# GitLab or GitHub Actions.
#
###################################

# Creates a new IAM OIDC provider.
# This resource is created only if oidc_provider_enabled is true AND oidc_use_existing_provider is false.
resource "aws_iam_openid_connect_provider" "oidc" {
  count = local.is_oidc_provider_enabled && !var.oidc_use_existing_provider ? 1 : 0

  url             = var.oidc_provider_url
  client_id_list  = var.oidc_client_id_list
  thumbprint_list = local.oidc_thumbprint_list_final # Uses fetched thumbprint if var.oidc_thumbprint_list is empty, otherwise uses var.oidc_thumbprint_list.

  tags = merge(
    local.common_tags,
    { Name = format("%s-provider", local.oidc_provider_host) } # e.g., gitlab.com-provider
  )
}

# Creates IAM roles that trust the OIDC provider.
# One role is created for each entry in var.oidc_roles if OIDC is enabled.
resource "aws_iam_role" "oidc" {
  for_each = local.is_oidc_provider_enabled ? { for role in var.oidc_roles : role.name => role } : {}

  name                 = each.value.name
  description          = each.value.description
  assume_role_policy   = data.aws_iam_policy_document.oidc_assume_role[each.key].json
  max_session_duration = each.value.max_session_duration

  tags = merge(
    local.common_tags,
    { Name = each.value.name }
  )

  # Ensure OIDC provider (created or data source) is processed before creating roles that trust it.
  depends_on = [
    aws_iam_openid_connect_provider.oidc,
    data.aws_iam_openid_connect_provider.existing
  ]
}

# Attaches managed IAM policies to the created OIDC roles.
# Iterates over the flattened list of role-to-policy_arn attachments prepared in locals.tf.
resource "aws_iam_role_policy_attachment" "oidc" {
  for_each = { for attachment in local.oidc_managed_policy_attachments : "${attachment.role_name}/${attachment.policy_arn}" => attachment }

  role       = aws_iam_role.oidc[each.value.role_name].name
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_role.oidc]
}

# Creates inline IAM policies for the OIDC roles.
# Iterates over the flattened list of inline policy definitions prepared in locals.tf.
resource "aws_iam_role_policy" "oidc_inline" {
  for_each = { for policy in local.oidc_inline_policy_definitions : "${policy.role_name}/${policy.policy_name}" => policy }

  name   = each.value.policy_name
  role   = aws_iam_role.oidc[each.value.role_name].id
  policy = each.value.policy_json

  depends_on = [aws_iam_role.oidc]
}
