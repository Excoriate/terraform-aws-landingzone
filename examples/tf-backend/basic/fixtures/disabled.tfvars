# Disabled fixture for the tf-backend basic example.
# This sets is_enabled to false to prevent the module resources from being created.

is_enabled = false

# Note: Even though the module is disabled, Terraform might still validate
# that required variables like domain_name, upstream_repo_name, and downstream_repo_name
# are present in variables.tf (even if not explicitly set here).
# The defaults in variables.tf satisfy this requirement.
# These values will not be used to create resources when is_enabled is false.
