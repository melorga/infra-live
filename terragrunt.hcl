# Root terragrunt.hcl
# This is the root configuration that all child configurations inherit from

locals {
  # Parse the file path to extract environment and region
  path_parts  = split("/", path_relative_to_include())
  environment = local.path_parts[0]
  region      = length(local.path_parts) > 1 ? local.path_parts[1] : null
  service     = length(local.path_parts) > 2 ? local.path_parts[2] : null

  # Load environment-specific variables
  env_vars = try(read_terragrunt_config(find_in_parent_folders("env.hcl", "env.hcl.notfound")), { inputs = {} })

  # Load region-specific variables  
  region_vars = try(read_terragrunt_config(find_in_parent_folders("region.hcl")), { inputs = {} })

  # Common tags applied to all resources
  common_tags = {
    Environment = local.environment
    Region      = local.region
    ManagedBy   = "Terragrunt"
    Repository  = "infra-live"
    LastUpdated = formatdate("YYYY-MM-DD", timestamp())
  }
}

# Configure remote state
remote_state {
  backend = "s3"
  config = {
    bucket         = "${try(local.env_vars.inputs.project_name, "infra-live")}-terraform-state-${local.environment}-${local.region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "${try(local.env_vars.inputs.project_name, "infra-live")}-terraform-locks-${local.environment}-${local.region}"

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
terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

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
  required_version = ">= 1.5"
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
