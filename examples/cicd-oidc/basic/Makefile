# Makefile for Landing Zone OIDC TF - Basic Example
# This file provides quick commands for testing the module with different fixtures

.PHONY: help init \
        plan-default plan-disabled \
        apply-default apply-disabled \
        destroy-default destroy-disabled \
        cycle-default cycle-disabled \
        clean docs

# Default target when just running 'make'
help:
	@echo "Landing Zone OIDC TF - Basic Example (GitLab)"
	@echo ""
	@echo "Usage: make <target>"
	@echo "Demonstrates basic OIDC setup for GitLab using the landing-zone-oidc-tf module."
	@echo "Ensure you customize gitlab.com:sub condition in main.tf before applying."
	@echo ""
	@echo "Available commands:"
	@echo "  make init                     - Initialize Terraform (terraform init)"
	@echo ""
	@echo "  Plan commands (terraform plan):"
	@echo "  make plan-default             - Plan with OIDC module enabled (uses fixtures/default.tfvars)"
	@echo "  make plan-disabled            - Plan with OIDC module disabled (uses fixtures/disabled.tfvars)"
	@echo ""
	@echo "  Apply commands (terraform apply -auto-approve):"
	@echo "  make apply-default            - Apply with OIDC module enabled"
	@echo "  make apply-disabled           - Apply with OIDC module disabled"
	@echo ""
	@echo "  Destroy commands (terraform destroy -auto-approve):"
	@echo "  make destroy-default          - Destroy resources with OIDC module enabled"
	@echo "  make destroy-disabled         - Destroy (no-op) with OIDC module disabled"
	@echo ""
	@echo "  Complete cycle commands (plan, apply, and destroy):"
	@echo "  make cycle-default            - Run full cycle with OIDC module enabled"
	@echo "  make cycle-disabled           - Run full cycle with OIDC module disabled"
	@echo ""
	@echo "  Utility commands:"
	@echo "  make docs                     - Generate README.md from .terraform-docs.yml"
	@echo "  make clean                    - Remove .terraform directory and other Terraform files"

# Initialize Terraform
init:
	@echo "Initializing Terraform in $(CURDIR)..."
	terraform init

# Plan commands
plan-default: init
	@echo "Planning with default fixture (OIDC module enabled)..."
	terraform plan -var-file=fixtures/default.tfvars
plan-disabled: init
	@echo "Planning with disabled fixture (OIDC module disabled)..."
	terraform plan -var-file=fixtures/disabled.tfvars

# Apply commands
apply-default: init
	@echo "Applying with default fixture (OIDC module enabled)..."
	terraform apply -var-file=fixtures/default.tfvars -auto-approve
apply-disabled: init
	@echo "Applying with disabled fixture (OIDC module disabled)..."
	terraform apply -var-file=fixtures/disabled.tfvars -auto-approve

# Destroy commands
destroy-default: init
	@echo "Destroying resources with default fixture (OIDC module enabled)..."
	terraform destroy -var-file=fixtures/default.tfvars -auto-approve
destroy-disabled: init
	@echo "Destroying resources with disabled fixture (OIDC module disabled)..."
	terraform destroy -var-file=fixtures/disabled.tfvars -auto-approve

# Run full cycle commands
cycle-default: plan-default apply-default destroy-default
	@echo "Completed full cycle with default fixture (OIDC module enabled)"
cycle-disabled: plan-disabled apply-disabled destroy-disabled
	@echo "Completed full cycle with disabled fixture (OIDC module disabled)"

# Generate documentation
docs:
	@echo "Generating README.md from .terraform-docs.yml..."
	terraform-docs markdown table --output-file README.md .

# Clean up Terraform files
clean:
	@echo "Cleaning up Terraform files in $(CURDIR)..."
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup .terraform.tfstate.lock.info
	@echo "Cleanup complete"
