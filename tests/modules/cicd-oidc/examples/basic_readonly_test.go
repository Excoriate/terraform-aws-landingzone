package examples

import (
	"testing"

	"github.com/Excoriate/terraform-aws-landingzone/tests/pkg/helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestCicdOidcBasicExamplePlanWhenEnabled verifies that the cicd-oidc/basic example
// can be initialized and planned successfully when the module is enabled.
// It performs the following steps:
// 1. Sets up the test environment with the cicd-oidc/basic example directory.
// 2. Initializes the Terraform module.
// 3. Creates a plan with the module enabled.
// 4. Verifies that the plan completes without errors and shows 'is_enabled = true'.
func TestCicdOidcBasicExamplePlanWhenEnabled(t *testing.T) {
	// Enable parallel test execution
	t.Parallel()

	// Create Terraform options with isolated provider cache for the cicd-oidc/basic example
	terraformOptions := helper.SetupTerraformOptions(t, "cicd-oidc/basic", map[string]interface{}{
		"is_enabled": true,
	})
	terraformOptions.Upgrade = true

	// Log the test context
	t.Logf("🔍 Testing example at directory: %s", terraformOptions.TerraformDir)

	// Execution phase - Initialize the module
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed for cicd-oidc/basic when enabled")
	t.Logf("✅ Terraform Init Output (cicd-oidc/basic, enabled): %s", initOutput)

	// Plan the module to verify configuration
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed for cicd-oidc/basic when enabled")
	t.Logf("📝 Terraform Plan Output (cicd-oidc/basic, enabled): %s", planOutput)

	// Verify is_enabled output is set to true (robust, whitespace-insensitive, color-code-insensitive)
	require.Regexp(t, `(?m)is_enabled\s*=\s*true`, planOutput, "Plan should include output is_enabled=true when module is enabled")
}

// TestCicdOidcBasicExampleValidate ensures that the cicd-oidc/basic example
// passes Terraform validation checks, verifying its structural integrity.
func TestCicdOidcBasicExampleValidate(t *testing.T) {
	// Enable parallel test execution
	t.Parallel()

	// Create Terraform options with isolated provider cache for the cicd-oidc/basic example
	// No specific vars needed here as 'is_enabled' defaults to true in the example's variables.tf,
	// which is suitable for validation.
	terraformOptions := helper.SetupTerraformOptions(t, "cicd-oidc/basic", map[string]interface{}{})
	terraformOptions.Upgrade = true

	// Log the test context
	t.Logf("🔍 Testing example for validation at directory: %s", terraformOptions.TerraformDir)

	// Execution phase - Initialize the module
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed for cicd-oidc/basic validation")
	t.Logf("✅ Terraform Init Output: %s", initOutput)

	// Validate the module to ensure structural integrity
	validateOutput, err := terraform.ValidateE(t, terraformOptions)
	require.NoError(t, err, "Terraform validation failed for cicd-oidc/basic")
	t.Logf("✅ Terraform Validate Output: %s", validateOutput)
}

// TestCicdOidcBasicExamplePlanWhenDisabled verifies that when the cicd-oidc/basic example
// has the module disabled, no significant resources are planned for creation.
func TestCicdOidcBasicExamplePlanWhenDisabled(t *testing.T) {
	// Enable parallel test execution
	t.Parallel()

	// Create Terraform options with isolated provider cache for the cicd-oidc/basic example
	terraformOptions := helper.SetupTerraformOptions(t, "cicd-oidc/basic", map[string]interface{}{
		"is_enabled": false,
	})
	terraformOptions.Upgrade = true

	// Log the test context
	t.Logf("🔍 Testing example at directory: %s with module disabled", terraformOptions.TerraformDir)

	// Execution phase - Initialize the module
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed for cicd-oidc/basic when disabled")
	t.Logf("✅ Terraform Init Output: %s", initOutput)

	// Plan the module to verify no resources are planned when disabled
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed for cicd-oidc/basic when disabled")
	t.Logf("📝 Terraform Plan Output: %s", planOutput)

	// Verify the plan does not contain key resource creation actions from the 'main' module
	require.NotContains(t, planOutput, "module.main.aws_iam_oidc_provider.this",
		"Plan should not include OIDC provider creation when module is disabled")
	require.NotContains(t, planOutput, "module.main.aws_iam_role.oidc_role",
		"Plan should not include IAM role creation when module is disabled")

	// Verify the plan does not include any resource additions
	require.NotContains(t, planOutput, "Plan: 1 to add",
		"Plan should not include any resource additions when module is disabled")
	require.NotContains(t, planOutput, " to add", // More general check for additions
		"Plan should not include any resource additions when module is disabled")

	// Verify is_enabled output is set to false (robust, whitespace-insensitive, color-code-insensitive)
	require.Regexp(t, `(?m)is_enabled\s*=\s*false`, planOutput, "Plan should include output is_enabled=false when module is disabled")
}
