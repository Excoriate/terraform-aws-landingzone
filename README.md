<h1 align="center">
  <img alt="logo" src="https://forum.huawei.com/enterprise/en/data/attachment/forum/202204/21/120858nak5g1epkzwq5gcs.png" width="224px"/><br/>

[![🧼 Pre-commit Hooks](https://github.com/Excoriate/terraform-aws-landingzone/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/Excoriate/terraform-aws-landingzone/actions/workflows/pre-commit.yml) [![📚 Terraform Modules CI](https://github.com/Excoriate/terraform-aws-landingzone/actions/workflows/tf-modules-ci.yaml/badge.svg)](https://github.com/Excoriate/terraform-aws-landingzone/actions/workflows/tf-modules-ci.yaml) [![🦫 Go Code Quality Checks](https://github.com/Excoriate/terraform-aws-landingzone/actions/workflows/go-linter.yaml/badge.svg)](https://github.com/Excoriate/terraform-aws-landingzone/actions/workflows/go-linter.yaml)
---

## Terraform AWS Landing Zone

This repository contains a collection of Terraform modules that are used to create a landing zone for AWS.


## Enabled Modules

| Module Name | Path | Description |
|-------------|------|-------------|
| OIDC Provider (CI/CD) | [modules/cicd-oidc](modules/cicd-oidc) | AWS IAM OIDC Provider for CI/CD federation |
| State Backend (S3/DynamoDB/IAM) | [modules/tf-backend](modules/tf-backend) | Secure, production-ready Terraform state backend with S3, DynamoDB, and IAM. |

---

### Usage

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Documentation References

- **Tests** (`/tests`):
  - [Testing Overview and Guidelines](/tests/README.md)
  - Comprehensive infrastructure testing using Terratest
  - Includes unit, integration, and validation tests

- **Scripts** (`/scripts`):
  - [Development Utilities and Workflow](/scripts/README.md)
  - Helper scripts for Git hooks, repository maintenance
  - Standardized development process automation

- **Modules** (`/modules`):
  - [Module Development Guidelines](/modules/README.md)
  - [Terraform Modules StyleGuide](/docs/terraform-styleguide/terraform-styleguide-modules.md)
  - Reusable, well-structured Terraform module implementations

- **Examples** (`/examples`):
  - [Module Usage Examples](/examples/README.md)
  - Practical configurations demonstrating module usage
  - Progressive complexity from basic to advanced scenarios

- **Docs** (`/docs`):
  - [Developer Tools Guide](/docs/guides/development-tools-guide.md)
  - Terraform StyleGuide:
    - [Code Guidelines](/docs/terraform-styleguide/terraform-styleguide-code.md)
    - [Modules Guidelines](/docs/terraform-styleguide/terraform-styleguide-modules.md)
    - [Examples Guidelines](/docs/terraform-styleguide/terraform-styleguide-examples.md)
    - [Terratest Guidelines](/docs/terraform-styleguide/terraform-styleguide-terratest.md)
  - [Project Roadmap](/docs/ROADMAP.md)
  - Comprehensive project documentation and future plans

**📘 Additional Resources:**
- [Contribution Guidelines](CONTRIBUTING.md)
- [Terraform Registry Module Best Practices](/docs/terraform-styleguide/terraform-styleguide-modules.md)
