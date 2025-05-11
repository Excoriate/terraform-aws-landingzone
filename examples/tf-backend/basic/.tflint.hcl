config {
  force = false
  # This is an example (root module) configuration.
  module = false
  exclude_paths = ["fixtures/*.tfvars"]
}

plugin "aws" {
  enabled = true
  version = "0.38.0" # Using version specified in style guide
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Mandatory Rules - Always Enabled
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_lookup" {
  enabled = true
}

rule "terraform_empty_list_equality" {
  enabled = true
}

rule "terraform_map_duplicate_keys" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

# Documentation Quality Rules
# terraform_documented_variables and terraform_documented_outputs are less critical for examples
# where variables.tf and outputs.tf might be intentionally minimal or empty.
rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

# Code Quality Rules
rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  # Often disabled in examples as not all module outputs might be used directly in the example's outputs,
  # or variables might be defined for flexibility but not used in a specific basic scenario.
  enabled = false
}

rule "terraform_unused_required_providers" {
  enabled = true
}

# AWS specific rules (examples)
rule "aws_iam_role_invalid_assume_role_policy" {
  enabled = true
}
