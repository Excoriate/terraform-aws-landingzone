# Makefile for tf-backend - Basic Example
# This file provides quick commands for testing the module with different fixtures

.PHONY: help init \
        plan-default plan-disabled \
        apply-default apply-disabled \
        destroy-default destroy-disabled \
        cycle-default cycle-disabled \
        clean docs

# Default target when just running 'make'
help:
	@echo "tf-backend - Basic Example"
	@echo ""
	@echo "Usage: make <target>"
	@echo "Demonstrates production-grade backend setup using the tf-backend module."
	@echo ""
	@echo "Available commands:"
	@echo "  make init                     - Initialize Terraform (terraform init)"
	@echo ""
	@echo "  Plan commands (terraform plan):"
	@echo "  make plan-default             - Plan with backend enabled (uses fixtures/default.tfvars)"
	@echo "  make plan-disabled            - Plan with backend disabled (uses fixtures/disabled.tfvars)"
	@echo ""
	@echo "  Apply commands (terraform apply -auto-approve):"
	@echo "  make apply-default            - Apply with backend enabled"
	@echo "  make apply-disabled           - Apply with backend disabled"
	@echo ""
	@echo "  Destroy commands (terraform destroy -auto-approve):"
	@echo "  make destroy-default          - Destroy resources with backend enabled"
	@echo "  make destroy-disabled         - Destroy (no-op) with backend disabled"
	@echo ""
	@echo "  Complete cycle commands (plan, apply, and destroy):"
	@echo "  make cycle-default            - Run full cycle with backend enabled"
	@echo "  make cycle-disabled           - Run full cycle with backend disabled"
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
	@echo "Planning with default fixture (backend enabled)..."
	terraform plan -var-file=fixtures/default.tfvars
plan-disabled: init
	@echo "Planning with disabled fixture (backend disabled)..."
	terraform plan -var-file=fixtures/disabled.tfvars

# Apply commands
apply-default: init
	@echo "Applying with default fixture (backend enabled)..."
	terraform apply -var-file=fixtures/default.tfvars -auto-approve
apply-disabled: init
	@echo "Applying with disabled fixture (backend disabled)..."
	terraform apply -var-file=fixtures/disabled.tfvars -auto-approve

# Destroy commands
destroy-default: init
	@echo "Destroying resources with default fixture (backend enabled)..."
	terraform destroy -var-file=fixtures/default.tfvars -auto-approve
destroy-disabled: init
	@echo "Destroying resources with disabled fixture (backend disabled)..."
	terraform destroy -var-file=fixtures/disabled.tfvars -auto-approve

# Run full cycle commands
cycle-default: plan-default apply-default destroy-default
	@echo "Completed full cycle with default fixture (backend enabled)"
cycle-disabled: plan-disabled apply-disabled destroy-disabled
	@echo "Completed full cycle with disabled fixture (backend disabled)"

# Generate documentation
docs:
	@echo "Generating README.md from .terraform-docs.yml..."
	terraform-docs markdown table --output-file README.md .

# Clean up Terraform files
clean:
	@echo "Cleaning up Terraform files in $(CURDIR)..."
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup .terraform.tfstate.lock.info
	@echo "Cleanup complete"
