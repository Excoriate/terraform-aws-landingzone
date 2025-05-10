###################################
# Terraform Configuration 🔧
# ----------------------------------------------------
#
# This section defines the required Terraform and provider versions
# for this module. It ensures compatibility and consistent behavior
# across different environments.
#
###################################

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.91.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}
