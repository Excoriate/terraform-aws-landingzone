//go:build unit && readonly

package unit

import (
	"testing"

	"github.com/Excoriate/terraform-aws-landingzone/tests/pkg/helper"
	// Removed "github.com/Excoriate/terraform-aws-landingzone/tests/pkg/repo" as dirs.GetModulesDir is no longer used
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestCicdOidcUnitBasicTargetInit verifies that the Terraform module's 'basic' target configuration
// can be successfully initialized with upgrade enabled.
func TestCicdOidcUnitBasicTargetInit(t *testing.T) {
	t.Parallel()

	// Use helper to set up terraform options for the 'cicd-oidc' module's 'basic' target
	// with an isolated provider cache.
	// Vars are empty, assuming tests/modules/cicd-oidc/target/basic/main.tf is self-contained
	// and sets is_enabled = true and other required inputs for the cicd-oidc module.
	terraformOptions := helper.SetupTargetTerraformOptions(t, "cicd-oidc", "basic", map[string]interface{}{})
	terraformOptions.Upgrade = true

	t.Logf("🔍 Terraform Target Directory for 'cicd-oidc/basic': %s", terraformOptions.TerraformDir)

	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed for 'cicd-oidc' module, 'basic' target")
	t.Log("✅ Terraform Init Output ('cicd-oidc' module, 'basic' target):
", initOutput)
}

// TestCicdOidcUnitBasicTargetValidate ensures that the 'cicd-oidc' module's 'basic' target configuration
// passes Terraform validation checks, verifying its structural integrity.
func TestCicdOidcUnitBasicTargetValidate(t *testing.T) {
	t.Parallel()

	// Use helper to set up terraform options for the 'cicd-oidc' module's 'basic' target
	// with an isolated provider cache.
	terraformOptions := helper.SetupTargetTerraformOptions(t, "cicd-oidc", "basic", map[string]interface{}{})
	terraformOptions.Upgrade = true

	t.Logf("🔍 Terraform Target Directory for 'cicd-oidc/basic' validation: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed for 'cicd-oidc' module, 'basic' target validation")
	t.Log("✅ Terraform Init Output ('cicd-oidc' module, 'basic' target validation):
", initOutput)

	// Validate with detailed error output
	validateOutput, err := terraform.ValidateE(t, terraformOptions)
	require.NoError(t, err, "Terraform validate failed for 'cicd-oidc' module, 'basic' target")
	t.Log("✅ Terraform Validate Output ('cicd-oidc' module, 'basic' target):
", validateOutput)
}
