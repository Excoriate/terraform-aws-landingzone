//go:build unit && readonly

package unit

import (
	"testing"

	"github.com/Excoriate/terraform-aws-landingzone/tests/pkg/helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestCicdOidcUnitDisabledTargetPlanVerifiesBehavior checks that the 'cicd-oidc' module's 'disabled_module' target configuration,
// when planned, correctly shows 'is_enabled = false' in the output and does not plan any OIDC-specific resources.
func TestCicdOidcUnitDisabledTargetPlanVerifiesBehavior(t *testing.T) {
	t.Parallel()

	// Use helper to set up terraform options for the 'cicd-oidc' module's 'disabled_module' target.
	// Vars are nil, assuming tests/modules/cicd-oidc/target/disabled_module/main.tf sets is_enabled = false.
	terraformOptions := helper.SetupTargetTerraformOptions(t, "cicd-oidc", "disabled_module", nil)
	terraformOptions.Upgrade = true
	// Ensure NoColor is set for consistent plan output parsing, if needed for specific string checks.
	terraformOptions.NoColor = true

	t.Logf("🔍 Terraform Target Directory for 'cicd-oidc/disabled_module': %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed for 'cicd-oidc' module, 'disabled_module' target")
	t.Log("✅ Terraform Init Output ('cicd-oidc' module, 'disabled_module' target):
", initOutput)

	// Plan to show what would be created in the disabled_module target
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed for 'cicd-oidc' module, 'disabled_module' target")
	t.Log("📝 Terraform Plan Output ('cicd-oidc' module, 'disabled_module' target):
", planOutput)

	// Verify plan contains the expected output for is_enabled
	require.Contains(t, planOutput, "is_enabled = false", "Plan should show is_enabled output as false when module is disabled")

	// Verify plan does not include key OIDC resource types that would be created by the cicd-oidc module
	require.NotContains(t, planOutput, "aws_iam_openid_connect_provider", "Plan should not include aws_iam_openid_connect_provider resource when module is disabled")
	require.NotContains(t, planOutput, "aws_iam_role", "Plan should not include aws_iam_role resource when module is disabled")

	// Verify the plan does not include any new resource additions
	require.NotContains(t, planOutput, "Plan: 1 to add",
		"Plan should not include any resource additions when module is disabled")
	require.NotContains(t, planOutput, " to add", // A more general check for additions
		"Plan should not include any resource additions when module is disabled")
}

// TestPlanningOnTargetWhenModuleDisabled verifies that the module
// correctly skips resource creation when disabled via is_enabled = false.
func TestPlanningOnTargetWhenModuleDisabled(t *testing.T) {
	t.Parallel()

	// Use helper to set up terraform options with isolated provider cache
	terraformOptions := helper.SetupTargetTerraformOptions(t, "default", "disabled_module", nil)
	terraformOptions.Upgrade = true

	t.Logf("🔍 Terraform Target Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan to show what would be created in the disabled_module target
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Verify plan contains the expected outputs
	require.Contains(t, planOutput, "is_enabled = false", "Plan should show is_enabled output as false")
	require.NotContains(t, planOutput, "random_string.random_text", "Plan should not include random_string resource when module is disabled")
}

// TestOutputsOnTargetWhenModuleDisabled verifies that the module outputs
// are correctly set when the module is disabled.
func TestOutputsOnTargetWhenModuleDisabled(t *testing.T) {
	t.Parallel()

	// Use helper to set up terraform options with isolated provider cache
	terraformOptions := helper.SetupTargetTerraformOptions(t, "default", "disabled_module", nil)
	terraformOptions.Upgrade = true

	// Add NoColor option for consistent output
	terraformOptions.NoColor = true

	t.Logf("🔍 Terraform Target Directory: %s", terraformOptions.TerraformDir)

	// Pre-initialize the module separately to make sure we have the correct module locally
	// This helps with test isolation and module cache issues
	moduleInitOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformOptions.TerraformDir,
		NoColor:      true,
		Lock:         false,
		EnvVars:      terraformOptions.EnvVars,
	})

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, moduleInitOptions)
	require.NoError(t, err, "Terraform module init failed")
	t.Log("✅ Terraform Module Init Output:\n", initOutput)

	// Plan to show what would be created in the disabled_module target
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Verify plan contains the expected outputs
	require.Contains(t, planOutput, "is_enabled = false", "Plan should show is_enabled output as false")
}
