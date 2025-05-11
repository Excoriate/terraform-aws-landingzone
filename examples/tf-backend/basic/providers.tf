###################################
# Provider Configuration
# ----------------------------------------------------
#
# This file configures the AWS provider for the example.
# The region is set via the aws_region variable.
#
###################################

provider "aws" {
  region = var.aws_region
}
