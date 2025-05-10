###################################
# Module Variables 📝
# ----------------------------------------------------
#
# This section defines the variables that can be customized when
# using this module. Each variable includes a description of its
# purpose and any validation rules that apply.
#
###################################

###################################
# Module Feature Flags 🎯
###################################
variable "is_enabled" {
  description = <<-DESC
  Controls whether the OIDC provider and associated roles are created.
  Setting this to `false` will prevent any resources in this module from being created.
  This is the primary feature flag for the entire module.
  DESC
  type        = bool
  default     = true
}

###################################
# Common Tags Variables 🏷️
###################################
variable "tags" {
  description = <<-DESC
  A map of tags to apply to all taggable resources created by this module.
  **Tags** are key-value pairs that you can assign to AWS resources. They can help you manage, identify, organize, search for, and filter resources.
  DESC
  type        = map(string)
  default     = {}
}


###################################
# OIDC Provider Variables 🔑
###################################

variable "oidc_use_existing_provider" {
  description = <<-DESC
  A boolean flag to determine whether to use an existing IAM OIDC provider.
  If `true`, the module will not create a new OIDC provider but will use the provider identified by `oidc_provider_url` (for lookup).
  An **IAM OIDC Provider** in AWS refers to an entity within IAM that establishes trust between your AWS account and an OIDC-compatible identity provider (IdP). This trust allows users authenticated by the IdP to assume IAM roles in your AWS account.
  DESC
  type        = bool
  default     = false
}

variable "oidc_provider_url" {
  description = <<-DESC
  The URL of the OpenID Connect identity provider.
  This URL must begin with `https://` and is used by AWS to establish trust with the OIDC provider.
  For example, for GitLab, it would be `https://gitlab.com`; for GitHub Actions, `https://token.actions.githubusercontent.com`.
  This URL is a critical component for identifying the OIDC provider.
  DESC
  type        = string
  # No default, this is mandatory if is_enabled is true.
  # Validation could be added to ensure it starts with https://
}

variable "oidc_client_id_list" {
  description = <<-DESC
  A list of client IDs (also known as audiences).
  These are the intended recipients of the OIDC token. For IAM roles, this is typically the OIDC provider's URL or a specific audience value like `sts.amazonaws.com`.
  For GitLab, `["https://gitlab.com"]` is a common value. For GitHub Actions, it's often `["sts.amazonaws.com"]`.
  The OIDC token's `aud` claim must match one of these client IDs.
  DESC
  type        = list(string)
  # No default, this is mandatory if is_enabled is true.
}

variable "oidc_thumbprint_list" {
  description = <<-DESC
  A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificates.
  A **Thumbprint** refers to a condensed, unique representation of a digital certificate's data, typically generated using a cryptographic hash function like SHA-1. In the context of AWS IAM OIDC providers, thumbprints are used to verify the authenticity of the OIDC identity provider's server certificate, ensuring that AWS is communicating with the legitimate provider.
  If this list is empty, the module will attempt to fetch the thumbprint automatically from the `oidc_provider_url` (if creating a new provider).
  It is recommended to provide this value for production environments to avoid issues if the provider's certificate changes unexpectedly and the fetch mechanism fails or retrieves an untrusted thumbprint.
  DESC
  type        = list(string)
  default     = []
}

variable "oidc_roles" {
  description = <<-DESC
  A list of objects, where each object defines an IAM role to be created that trusts the OIDC provider.
  An **IAM Role** is an AWS identity with permission policies that determine what the identity can and cannot do in AWS. Roles are meant to be assumed by trusted entities, such as users, applications, or services.
  In this OIDC context, these roles will be assumable by identities authenticated by the OIDC provider, based on the conditions specified in `assume_role_conditions`.

  Each object in the list has the following attributes:
  - `name` (string): The name of the IAM role.
  - `description` (string, optional): A description for the IAM role. Default: "OIDC federated role".
  - `max_session_duration` (number, optional): The maximum session duration (in seconds) for the IAM role. Default: `3600`. Min: `3600`, Max: `43200`.
  - `assume_role_conditions` (list(object), optional): A list of conditions to include in the role's trust policy (Assume Role Policy document). Each condition object has:
    - `test` (string): The condition test (e.g., "StringEquals", "StringLike").
    - `variable` (string): The variable to test in the token (e.g., `your.oidc.provider.com:sub`, `your.oidc.provider.com:aud`). The prefix should match the OIDC provider URL (host part).
    - `values` (list(string)): The values for the condition test.
  - `managed_policy_arns` (list(string), optional): A list of ARNs of IAM managed policies to attach to the role. A **Managed Policy** is a standalone IAM policy that you can attach to multiple users, groups, and roles in your AWS account.
  - `inline_policies` (list(object), optional): A list of inline policies to embed in the role. An **Inline Policy** is an IAM policy that is embedded directly into a single user, group, or role. Each inline policy object has:
    - `name` (string): The name of the inline policy.
    - `policy_json` (string): The policy document in JSON format.
  DESC
  type = list(object({
    name                 = string
    description          = optional(string, "OIDC federated role")
    max_session_duration = optional(number, 3600)
    assume_role_conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
    managed_policy_arns = optional(list(string), [])
    inline_policies = optional(list(object({
      name        = string
      policy_json = string
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for role in var.oidc_roles : (
        role.max_session_duration >= 3600 && role.max_session_duration <= 43200
      )
    ])
    error_message = "The max_session_duration for all roles must be between 3600 and 43200 seconds."
  }
}
