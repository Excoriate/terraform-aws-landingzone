# This data source is not strictly necessary for the module call itself if not used directly here,
# but can be useful for providing certain values (like account ID) to the module if needed.
# For this basic example, we'll keep it minimal as per the requirements for the example.
data "aws_caller_identity" "current" {}

# Call the landing-zone-oidc-tf module to set up OIDC for GitLab.
module "main" {
  source = "../../../modules/landing-zone-oidc"

  is_enabled          = var.is_enabled # Controlled by fixtures (default.tfvars, disabled.tfvars)
  oidc_provider_url   = "https://gitlab.com"
  oidc_client_id_list = ["https://gitlab.com"] # Common audience for GitLab OIDC integration with AWS.

  # Define a role for GitLab CI/CD pipelines.
  # The assume_role_conditions will ensure that only specific projects/branches can assume this role.
  oidc_roles = [
    {
      name        = "gitlab-ci-basic-role" # A descriptive name for the role.
      description = "IAM role for GitLab CI/CD basic example, assumed via OIDC."
      # max_session_duration = 3600 # Default is 3600, can be overridden if needed.

      assume_role_conditions = [
        {
          test = "StringEquals"
          # The variable format is usually `<OIDC_PROVIDER_HOST>:<CLAIM_NAME>`.
          # For GitLab, the host is `gitlab.com` and a common claim is `sub` (subject).
          variable = "gitlab.com:sub" # This should match the host part of oidc_provider_url.
          # Example value: Restrict to a specific project, branch type, and branch name.
          # Replace `your-gitlab-group/your-gitlab-project` and `main` with actual values.
          values = ["project_path:your-gitlab-group/your-gitlab-project:ref_type:branch:ref:main"]
        },
        {
          # It's also good practice to check the audience if your IdP supports it well in this context.
          # GitLab might include the client_id in the `aud` claim.
          test     = "StringEquals"
          variable = "gitlab.com:aud"
          values   = ["https://gitlab.com"] # Matches one of the oidc_client_id_list values.
        }
      ]

      # Attach a managed policy for basic permissions (e.g., ReadOnlyAccess for testing).
      # Replace with more specific policies as needed for your CI/CD tasks.
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

      # Example of an inline policy (optional).
      # inline_policies = [
      #   {
      #     name = "gitlab-ci-custom-s3-access"
      #     policy_json = jsonencode({
      #       Version = "2012-10-17",
      #       Statement = [
      #         {
      #           Effect   = "Allow",
      #           Action   = ["s3:ListBucket"],
      #           Resource = ["arn:aws:s3:::your-specific-bucket"]
      #         }
      #       ]
      #     })
      #   }
      # ]
    }
  ]

  tags = {
    Example     = "landing-zone-oidc-tf-basic"
    Environment = "development"
    CreatedBy   = "Terraform"
  }
}
