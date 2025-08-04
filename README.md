# Live Infrastructure Repository

This repository contains the live infrastructure configurations using Terragrunt to deploy the reusable Terraform modules from the `iac-modules` repository.

## Repository Structure

```
infra-live/
├── terragrunt.hcl              # Root Terragrunt configuration
├── dev/                        # Development environment
│   ├── us-east-1/              # AWS region
│   │   ├── region.hcl          # Region-specific configuration
│   │   ├── vpc/                # VPC infrastructure
│   │   │   └── terragrunt.hcl
│   │   ├── eks/                # EKS cluster
│   │   │   └── terragrunt.hcl
│   │   └── rds/                # RDS database
│   │       └── terragrunt.hcl
│   └── env.hcl                 # Environment-specific variables
├── stage/                      # Staging environment
│   └── us-east-1/
└── prod/                       # Production environment
    └── us-east-1/

```

## Environment Structure

- **dev/**: Development environment with basic resources
- **stage/**: Staging environment for testing
- **prod/**: Production environment with high availability

## Deployment

Use Terragrunt commands to deploy infrastructure:

```bash
# Plan all changes
terragrunt plan-all

# Apply all changes
terragrunt apply-all

# Destroy resources (use with caution)
terragrunt destroy-all
```

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed (>= 1.5.7)
3. Terragrunt installed (>= 0.58.7)
4. Appropriate AWS permissions for resource creation
