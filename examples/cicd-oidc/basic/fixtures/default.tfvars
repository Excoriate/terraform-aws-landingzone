# Default fixture for the landing-zone-oidc-tf basic example.
# This enables the module instance.

is_enabled = true

# Note: Specific GitLab conditions like project_path and ref are set directly
# in the examples/landing-zone-oidc-tf/basic/main.tf module call for this basic example.
# For more dynamic examples, these could be exposed as example-level variables
# and set via .tfvars files.

# Use the default external_connection ("public:npmjs") defined in variables.tf
# Or uncomment below to override:
# external_connection = "public:pypi"

# All other variables use the defaults specified in variables.tf
# (e.g., domain_name, upstream_repo_name, downstream_repo_name, aws_region, tags)
# policy_principal_arn defaults to null, using the current caller identity.
