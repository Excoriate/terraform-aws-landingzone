<!-- BEGIN_TF_DOCS -->
# Terraform AWS IAM OIDC Provider Module

## Overview
> **Note:** This module provides a standardized way to configure an AWS IAM OpenID Connect (OIDC) provider and associated IAM roles. It supports creating a new OIDC provider or using an existing one, and allows for detailed configuration of IAM roles including trust policies, managed policies, and inline policies.

### 🚀 Key Features
- Creates or uses an existing IAM OIDC provider.
- Automatically fetches OIDC provider certificate thumbprints if not provided.
- Configures multiple IAM roles with OIDC trust relationships.
- Customizable assume role conditions for fine-grained access control.
- Supports attaching both managed and inline IAM policies to roles.
- Adheres to provided Terraform style guides for structure and conventions.

### 📖 Usage Guidelines
1. **Provider Configuration**: Ensure your AWS provider is configured correctly.
2. **OIDC Provider URL**: Specify the `oidc_provider_url` (e.g., `https://gitlab.com` or `https://token.actions.githubusercontent.com`).
3. **Client IDs**: Provide the `oidc_client_id_list` (audiences).
4. **Roles**: Define roles using the `oidc_roles` variable, specifying names, conditions, and policies.
   - For GitLab, `assume_role_conditions` variable might look like: `"gitlab.com:sub"` for subject claim checks.
   - For GitHub Actions, conditions typically involve `"token.actions.githubusercontent.com:sub"` and `"token.actions.githubusercontent.com:aud"`.
5. **Existing Provider**: If using an existing OIDC provider, set `oidc_use_existing_provider = true` and ensure `oidc_provider_url` matches the existing provider's URL.

```hcl
module "oidc_config" {
  source = "./modules/landing-zone-oidc-tf" # Or your module source

  is_enabled          = true
  oidc_provider_url   = "https://gitlab.com" # Replace with your OIDC provider URL
  oidc_client_id_list = ["https://gitlab.com"] # Replace with your client ID(s)

  oidc_roles = [
    {
      name        = "gitlab-ci-role-example"
      description = "Role for GitLab CI to access AWS resources"
      assume_role_conditions = [
        {
          test     = "StringEquals"
          variable = "gitlab.com:sub" # Note: Use host from oidc_provider_url
          values   = ["project_path:your-group/your-project:ref_type:branch:ref:main"]
        }
      ]
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "oidc-integration"
  }
}
```



## Requirements



## Providers



## Modules



## Resources

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.oidc_inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oidc_client_id_list"></a> [oidc\_client\_id\_list](#input\_oidc\_client\_id\_list) | A list of client IDs (also known as audiences).<br/>These are the intended recipients of the OIDC token. For IAM roles, this is typically the OIDC provider's URL or a specific audience value like `sts.amazonaws.com`.<br/>For GitLab, `["https://gitlab.com"]` is a common value. For GitHub Actions, it's often `["sts.amazonaws.com"]`.<br/>The OIDC token's `aud` claim must match one of these client IDs. | `list(string)` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | The URL of the OpenID Connect identity provider.<br/>This URL must begin with `https://` and is used by AWS to establish trust with the OIDC provider.<br/>For example, for GitLab, it would be `https://gitlab.com`; for GitHub Actions, `https://token.actions.githubusercontent.com`.<br/>This URL is a critical component for identifying the OIDC provider. | `string` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Controls whether the OIDC provider and associated roles are created.<br/>Setting this to `false` will prevent any resources in this module from being created.<br/>This is the primary feature flag for the entire module. | `bool` | `true` | no |
| <a name="input_oidc_roles"></a> [oidc\_roles](#input\_oidc\_roles) | A list of objects, where each object defines an IAM role to be created that trusts the OIDC provider.<br/>An **IAM Role** is an AWS identity with permission policies that determine what the identity can and cannot do in AWS. Roles are meant to be assumed by trusted entities, such as users, applications, or services.<br/>In this OIDC context, these roles will be assumable by identities authenticated by the OIDC provider, based on the conditions specified in `assume_role_conditions`.<br/><br/>Each object in the list has the following attributes:<br/>- `name` (string): The name of the IAM role.<br/>- `description` (string, optional): A description for the IAM role. Default: "OIDC federated role".<br/>- `max_session_duration` (number, optional): The maximum session duration (in seconds) for the IAM role. Default: `3600`. Min: `3600`, Max: `43200`.<br/>- `assume_role_conditions` (list(object), optional): A list of conditions to include in the role's trust policy (Assume Role Policy document). Each condition object has:<br/>  - `test` (string): The condition test (e.g., "StringEquals", "StringLike").<br/>  - `variable` (string): The variable to test in the token (e.g., `your.oidc.provider.com:sub`, `your.oidc.provider.com:aud`). The prefix should match the OIDC provider URL (host part).<br/>  - `values` (list(string)): The values for the condition test.<br/>- `managed_policy_arns` (list(string), optional): A list of ARNs of IAM managed policies to attach to the role. A **Managed Policy** is a standalone IAM policy that you can attach to multiple users, groups, and roles in your AWS account.<br/>- `inline_policies` (list(object), optional): A list of inline policies to embed in the role. An **Inline Policy** is an IAM policy that is embedded directly into a single user, group, or role. Each inline policy object has:<br/>  - `name` (string): The name of the inline policy.<br/>  - `policy_json` (string): The policy document in JSON format. | <pre>list(object({<br/>    name                 = string<br/>    description          = optional(string, "OIDC federated role")<br/>    max_session_duration = optional(number, 3600)<br/>    assume_role_conditions = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })), [])<br/>    managed_policy_arns = optional(list(string), [])<br/>    inline_policies = optional(list(object({<br/>      name        = string<br/>      policy_json = string<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_oidc_thumbprint_list"></a> [oidc\_thumbprint\_list](#input\_oidc\_thumbprint\_list) | A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificates.<br/>A **Thumbprint** refers to a condensed, unique representation of a digital certificate's data, typically generated using a cryptographic hash function like SHA-1. In the context of AWS IAM OIDC providers, thumbprints are used to verify the authenticity of the OIDC identity provider's server certificate, ensuring that AWS is communicating with the legitimate provider.<br/>If this list is empty, the module will attempt to fetch the thumbprint automatically from the `oidc_provider_url` (if creating a new provider).<br/>It is recommended to provide this value for production environments to avoid issues if the provider's certificate changes unexpectedly and the fetch mechanism fails or retrieves an untrusted thumbprint. | `list(string)` | `[]` | no |
| <a name="input_oidc_use_existing_provider"></a> [oidc\_use\_existing\_provider](#input\_oidc\_use\_existing\_provider) | A boolean flag to determine whether to use an existing IAM OIDC provider.<br/>If `true`, the module will not create a new OIDC provider but will use the provider identified by `oidc_provider_url` (for lookup).<br/>An **IAM OIDC Provider** in AWS refers to an entity within IAM that establishes trust between your AWS account and an OIDC-compatible identity provider (IdP). This trust allows users authenticated by the IdP to assume IAM roles in your AWS account. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all taggable resources created by this module.<br/>**Tags** are key-value pairs that you can assign to AWS resources. They can help you manage, identify, organize, search for, and filter resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_feature_flags"></a> [feature\_flags](#output\_feature\_flags) | A map of feature flags indicating the status of various module functionalities. |
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Indicates whether the OIDC module and its resources are enabled. |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the IAM OIDC provider. This will be the ARN of the newly created provider or the existing one if `oidc_use_existing_provider` was true. |
| <a name="output_oidc_role_arns"></a> [oidc\_role\_arns](#output\_oidc\_role\_arns) | A map of the created IAM role ARNs, where keys are role names. |
| <a name="output_oidc_roles"></a> [oidc\_roles](#output\_oidc\_roles) | A map of the created IAM roles, where keys are role names and values are objects containing role ARN, ID, and name. |
| <a name="output_tags_set"></a> [tags\_set](#output\_tags\_set) | The final set of tags applied to resources by this module. |
<!-- END_TF_DOCS -->