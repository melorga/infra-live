# Root terragrunt.hcl
# This is the root configuration that all child configurations inherit from.

# Terragrunt 1.0 (released May 2026) introduced breaking changes — notably
# the new CAS (Content-Addressable Store), hcl fmt, and experiments framework.
# See https://terragrunt.gruntwork.io/docs/migrate/migrating-from-0xx/ for
# upgrade guidance before bumping local installs.
terragrunt_version_constraint  = ">= 1.0"
terraform_version_constraint   = ">= 1.9, < 2.0"

locals {
  # Parse the file path to extract environment and region
  path_parts  = split("/", path_relative_to_include())
  environment = local.path_parts[0]
  region      = length(local.path_parts) > 1 ? local.path_parts[1] : null
  service     = length(local.path_parts) > 2 ? local.path_parts[2] : null

  # Where reusable Terraform modules live. Component configs append the
  # module sub-path and a `?ref=` pin, e.g.:
  #   source = "${include.root.locals.module_base_path}/vpc-network?ref=v1.2.3"
  module_base_path = "git::https://github.com/melorga/iac-modules.git//modules"

  # Load environment-specific variables. Fail loudly if env.hcl is missing
  # rather than silently returning empty inputs.
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Load region-specific variables (optional).
  region_vars = try(read_terragrunt_config(find_in_parent_folders("region.hcl")), { inputs = {} })

  # Common tags applied to all resources. Intentionally no time-based tags
  # here — including `timestamp()` causes state drift on every plan/apply.
  common_tags = {
    Environment = local.environment
    Region      = local.region
    ManagedBy   = "Terragrunt"
    Repository  = "infra-live"
  }
}

# Configure remote state
remote_state {
  backend = "s3"
  config = {
    bucket         = "${try(local.env_vars.locals.project_name, "infra-live")}-terraform-state-${local.environment}-${local.region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "${try(local.env_vars.locals.project_name, "infra-live")}-terraform-locks-${local.environment}-${local.region}"

    s3_bucket_tags      = local.common_tags
    dynamodb_table_tags = local.common_tags
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"

  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}

# Generate versions configuration
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
EOF
}

# Configure inputs that all child configurations inherit
inputs = merge(
  try(local.env_vars.inputs, {}),
  try(local.region_vars.inputs, {}),
  {
    environment = local.environment
    region      = local.region
    common_tags = local.common_tags
  }
)
