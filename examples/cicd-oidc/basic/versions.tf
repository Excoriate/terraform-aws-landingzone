terraform {
  required_version = "= 1.8.0" # Compatible with the module's requirement

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Matching the module's constraint
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0" # Required by the underlying oidc module for thumbprint fetching
    }
  }
}
