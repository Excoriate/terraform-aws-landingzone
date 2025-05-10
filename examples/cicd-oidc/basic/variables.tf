variable "is_enabled" {
  description = "Controls whether the GitLab OIDC module example is enabled. This is typically controlled by fixture files (default.tfvars or disabled.tfvars)."
  type        = bool
  default     = true # Default to true, but fixtures will override.
}