<!-- BEGIN_TF_DOCS -->
# Terraform AWS State Backend Module

## Overview
> **Note:** This module provides a secure, production-ready backend for Terraform state management using S3, DynamoDB, and IAM. It supports encryption, versioning, state locking, replication, lifecycle, monitoring, and strict tagging, fully compliant with the project styleguides.

### 🚀 Key Features
- Encrypted S3 bucket (SSE-S3/SSE-KMS, CMK support, encryption enforcement)
- S3 versioning and lifecycle management
- DynamoDB state locking (PAY_PER_REQUEST/provisioned, PITR, TTL, deletion protection)
- S3 public access block and replication (optional)
- IAM role/policy management (create or accept, least privilege, cross-account/region)
- Tagging and metadata for all resources
- Monitoring/alerts (S3 logging, CloudWatch metrics/alarms)
- Cross-account/region flexibility (arn_format, principals)

### 📋 Usage Guidelines
1. Set required variables for S3, DynamoDB, and IAM as needed.
2. Enable/disable features via input variables (see below).
3. Use outputs to configure your Terraform backend and IAM access.



## Variables

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arn_format"></a> [arn\_format](#input\_arn\_format) | The ARN format to use for resources. Useful for AWS GovCloud or China regions. Valid values: "standard", "aws-cn", "aws-us-gov". | `string` | `"standard"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket to create for storing the Terraform state file. Must be globally unique. If not provided, a name will be auto-generated based on the project and environment. | `string` | `""` | no |
| <a name="input_cloudwatch_alarm_email"></a> [cloudwatch\_alarm\_email](#input\_cloudwatch\_alarm\_email) | The email address to notify for CloudWatch alarms. Required if `monitoring_enabled` is true. | `string` | `null` | no |
| <a name="input_dynamodb_billing_mode"></a> [dynamodb\_billing\_mode](#input\_dynamodb\_billing\_mode) | The billing mode for the DynamoDB table. Valid values are "PAY\_PER\_REQUEST" (on-demand) or "PROVISIONED". If "PROVISIONED", you must specify `dynamodb_read_capacity` and `dynamodb_write_capacity`. | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_dynamodb_deletion_protection_enabled"></a> [dynamodb\_deletion\_protection\_enabled](#input\_dynamodb\_deletion\_protection\_enabled) | Whether to enable deletion protection on the DynamoDB table to prevent accidental deletion. | `bool` | `true` | no |
| <a name="input_dynamodb_pitr_enabled"></a> [dynamodb\_pitr\_enabled](#input\_dynamodb\_pitr\_enabled) | Whether to enable Point-In-Time Recovery (PITR) for the DynamoDB table, allowing restoration to any point within the retention window. | `bool` | `true` | no |
| <a name="input_dynamodb_read_capacity"></a> [dynamodb\_read\_capacity](#input\_dynamodb\_read\_capacity) | The read capacity units for the DynamoDB table (only used if billing mode is PROVISIONED). | `number` | `5` | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | The name of the DynamoDB table to create for state locking. If not provided, a name will be auto-generated based on the project and environment. | `string` | `""` | no |
| <a name="input_dynamodb_ttl_attribute_name"></a> [dynamodb\_ttl\_attribute\_name](#input\_dynamodb\_ttl\_attribute\_name) | The name of the attribute to use for TTL on the DynamoDB table. Required if `dynamodb_ttl_enabled` is true. | `string` | `null` | no |
| <a name="input_dynamodb_ttl_enabled"></a> [dynamodb\_ttl\_enabled](#input\_dynamodb\_ttl\_enabled) | Whether to enable TTL (Time To Live) on the DynamoDB table. If enabled, you must specify `dynamodb_ttl_attribute_name`. | `bool` | `false` | no |
| <a name="input_dynamodb_write_capacity"></a> [dynamodb\_write\_capacity](#input\_dynamodb\_write\_capacity) | The write capacity units for the DynamoDB table (only used if billing mode is PROVISIONED). | `number` | `5` | no |
| <a name="input_iam_managed_policy_arns"></a> [iam\_managed\_policy\_arns](#input\_iam\_managed\_policy\_arns) | List of managed policy ARNs to attach to the IAM role. Only used if `iam_policy_attach_managed` is true. | `list(string)` | `[]` | no |
| <a name="input_iam_policy_attach_inline"></a> [iam\_policy\_attach\_inline](#input\_iam\_policy\_attach\_inline) | Whether to attach an inline policy granting least-privilege S3 and DynamoDB access to the IAM role. | `bool` | `true` | no |
| <a name="input_iam_policy_attach_managed"></a> [iam\_policy\_attach\_managed](#input\_iam\_policy\_attach\_managed) | Whether to attach managed policies to the IAM role. If true, you must provide `iam_managed_policy_arns`. | `bool` | `false` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | The ARN of an existing IAM role to use for backend access. Required if `iam_role_create` is false. | `string` | `null` | no |
| <a name="input_iam_role_create"></a> [iam\_role\_create](#input\_iam\_role\_create) | Whether to create a new IAM role for backend access. If false, you must provide `iam_role_arn`. | `bool` | `true` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | The name of the IAM role to create for Terraform backend access. If not provided, a name will be auto-generated. If you wish to use an existing role, set `iam_role_create` to false and provide `iam_role_arn`. | `string` | `""` | no |
| <a name="input_iam_trust_principals"></a> [iam\_trust\_principals](#input\_iam\_trust\_principals) | List of AWS principals (ARNs) that can assume the IAM role. Supports cross-account/region access. If not set, defaults to the current account root. | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Controls whether the backend resources (S3, DynamoDB, IAM, etc.) are created.<br/>Setting this to `false` will prevent any resources in this module from being created.<br/>This is the primary feature flag for the entire module. | `bool` | `true` | no |
| <a name="input_monitoring_enabled"></a> [monitoring\_enabled](#input\_monitoring\_enabled) | Whether to enable CloudWatch monitoring and alarms for S3 and DynamoDB resources. | `bool` | `false` | no |
| <a name="input_s3_encryption_type"></a> [s3\_encryption\_type](#input\_s3\_encryption\_type) | The type of server-side encryption to apply to the S3 bucket. Valid values are "SSE-S3" (default) or "SSE-KMS". If "SSE-KMS" is selected, you may specify a customer-managed KMS key via `s3_kms_key_arn`. | `string` | `"SSE-S3"` | no |
| <a name="input_s3_force_destroy"></a> [s3\_force\_destroy](#input\_s3\_force\_destroy) | Whether to enable force\_destroy on the S3 bucket, allowing all objects (including noncurrent versions) to be deleted when destroying the bucket. Should be `false` in production for safety. | `bool` | `false` | no |
| <a name="input_s3_kms_key_arn"></a> [s3\_kms\_key\_arn](#input\_s3\_kms\_key\_arn) | The ARN of the customer-managed KMS key to use for S3 bucket encryption when `s3_encryption_type` is "SSE-KMS". If not set and SSE-KMS is selected, a new KMS key will be created. | `string` | `null` | no |
| <a name="input_s3_lifecycle_days_to_glacier"></a> [s3\_lifecycle\_days\_to\_glacier](#input\_s3\_lifecycle\_days\_to\_glacier) | Number of days after which noncurrent object versions are transitioned to Glacier. Only used if `s3_lifecycle_enabled` is true. | `number` | `90` | no |
| <a name="input_s3_lifecycle_enabled"></a> [s3\_lifecycle\_enabled](#input\_s3\_lifecycle\_enabled) | Whether to enable lifecycle rules on the S3 bucket to transition or expire old state file versions (e.g., archive to Glacier after 90 days). | `bool` | `true` | no |
| <a name="input_s3_logging_bucket"></a> [s3\_logging\_bucket](#input\_s3\_logging\_bucket) | The name of the S3 bucket where server-access logs will be delivered. Required if `s3_logging_enabled` is true. | `string` | `null` | no |
| <a name="input_s3_logging_enabled"></a> [s3\_logging\_enabled](#input\_s3\_logging\_enabled) | Whether to enable server-access logging for the S3 bucket. If enabled, you must provide `s3_logging_bucket` and optionally `s3_logging_prefix`. | `bool` | `false` | no |
| <a name="input_s3_logging_prefix"></a> [s3\_logging\_prefix](#input\_s3\_logging\_prefix) | The prefix for S3 server-access logs. Optional. | `string` | `null` | no |
| <a name="input_s3_public_access_block_enabled"></a> [s3\_public\_access\_block\_enabled](#input\_s3\_public\_access\_block\_enabled) | Whether to block all public access to the S3 bucket (recommended). This enables all four public access block settings. | `bool` | `true` | no |
| <a name="input_s3_replica_bucket_arn"></a> [s3\_replica\_bucket\_arn](#input\_s3\_replica\_bucket\_arn) | The ARN of the destination S3 bucket for replication. Required if `s3_replication_enabled` is true. | `string` | `null` | no |
| <a name="input_s3_replica_role_arn"></a> [s3\_replica\_role\_arn](#input\_s3\_replica\_role\_arn) | The ARN of the IAM role to use for S3 replication. Required if `s3_replication_enabled` is true. | `string` | `null` | no |
| <a name="input_s3_replication_enabled"></a> [s3\_replication\_enabled](#input\_s3\_replication\_enabled) | Whether to enable cross-region or cross-account replication for the S3 bucket. If enabled, you must provide `s3_replica_bucket_arn` and `s3_replica_role_arn`. | `bool` | `false` | no |
| <a name="input_s3_versioning_enabled"></a> [s3\_versioning\_enabled](#input\_s3\_versioning\_enabled) | Whether to enable versioning on the S3 bucket. Versioning allows recovery from accidental deletions or corruption of the state file. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all taggable resources created by this module. Tags are key-value pairs for resource management, billing, and compliance. Recommended keys: Environment, Project, Owner, CostCenter. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | The ARN of the DynamoDB table used for state locking. |
| <a name="output_dynamodb_table_id"></a> [dynamodb\_table\_id](#output\_dynamodb\_table\_id) | The name (ID) of the DynamoDB table used for state locking. |
| <a name="output_feature_flags"></a> [feature\_flags](#output\_feature\_flags) | A map of feature flags indicating the status of various module functionalities. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The ARN of the IAM role to be assumed for backend access. |
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Indicates whether the OIDC module and its resources are enabled. |
| <a name="output_monitoring_enabled"></a> [monitoring\_enabled](#output\_monitoring\_enabled) | Indicates whether CloudWatch monitoring and alarms are enabled for S3 and DynamoDB resources. |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket used for Terraform state storage. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name (ID) of the S3 bucket used for Terraform state storage. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The AWS region where the S3 bucket is created. |
| <a name="output_tags_set"></a> [tags\_set](#output\_tags\_set) | The final set of tags applied to resources by this module. |

## Resources

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.encryption_enforcement](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
<!-- END_TF_DOCS -->