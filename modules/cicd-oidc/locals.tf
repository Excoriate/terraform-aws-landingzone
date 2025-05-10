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
  common_tags = merge(
    {
      "TerraformModule" = "landing-zone-oidc-tf"
    },
    var.tags
  )

  ###################################
  # OIDC Specific Locals 🔑
  # ----------------------------------------------------
  # Locals related to OIDC provider configuration.
  ###################################

  # Fetch OIDC provider thumbprints if not explicitly provided.
  # This is only done if creating a new provider.
  oidc_thumbprint_list_final = local.is_oidc_provider_enabled && !var.oidc_use_existing_provider && length(var.oidc_thumbprint_list) == 0 ? (
    # Relies on data.tls_certificate.oidc (defined in main.tf)
    [data.tls_certificate.oidc[0].certificates[0].sha1_fingerprint]
  ) : var.oidc_thumbprint_list

  # Determine the ARN of the OIDC provider to be used by IAM roles.
  effective_oidc_provider_arn = local.is_oidc_provider_enabled ? (
    var.oidc_use_existing_provider ? data.aws_iam_openid_connect_provider.existing[0].arn : aws_iam_openid_connect_provider.oidc[0].arn
  ) : null

  # Flatten the managed policy attachments for easy iteration in aws_iam_role_policy_attachment.
  oidc_managed_policy_attachments = flatten([
    for role_idx, role in var.oidc_roles : [
      for policy_arn in role.managed_policy_arns : {
        role_name  = role.name
        policy_arn = policy_arn
      }
    ]
    if local.is_oidc_provider_enabled
  ])

  # Flatten the inline policy definitions for easy iteration in aws_iam_role_policy.
  oidc_inline_policy_definitions = flatten([
    for role_idx, role in var.oidc_roles : [
      for inline_policy in role.inline_policies : {
        role_name   = role.name
        policy_name = inline_policy.name
        policy_json = inline_policy.policy_json
      }
    ]
    if local.is_oidc_provider_enabled
  ])

  # Prepare the OIDC provider URL host for assume role policy conditions.
  # e.g., from "https://gitlab.com" to "gitlab.com"
  oidc_provider_host = local.is_oidc_provider_enabled ? trimprefix(var.oidc_provider_url, "https://") : ""
}
