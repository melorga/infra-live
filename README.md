# Live Infrastructure Repository

[![Live Infrastructure CI/CD](https://github.com/melorga/infra-live/actions/workflows/terragrunt.yml/badge.svg)](https://github.com/melorga/infra-live/actions/workflows/terragrunt.yml)

This repository contains the live infrastructure configurations using
Terragrunt to deploy Terraform modules per environment.

## Repository Structure

```
infra-live/
├── terragrunt.hcl              # Root Terragrunt configuration
├── dev/                        # Development environment
│   ├── env.hcl                 # Environment-specific variables
│   └── us-east-1/              # AWS region
│       ├── region.hcl          # Region-specific configuration
│       ├── vpc/                # VPC stack
│       ├── eks/                # EKS stack (depends on vpc)
│       └── rds/                # RDS stack (depends on vpc)
├── stage/                      # Staging environment
│   ├── env.hcl
│   └── us-east-1/
│       └── vpc/
└── prod/                       # Production environment
    ├── env.hcl
    └── us-east-1/
        └── network/
```

## Environments

- **dev/**   — development, single NAT, deletion_protection off.
- **stage/** — pre-prod testing, multi-AZ, monitoring on.
- **prod/**  — production, multi-AZ, deletion_protection on, 30d backups,
  apply gated behind a GitHub Environment with required reviewers.

## Module sources

Until `melorga/iac-modules` ships first-party `vpc-network`, `eks` and
`rds` modules, the component `terraform.source` blocks point at the
public `terraform-aws-modules/{vpc,eks,rds}/aws` registry modules so
the stacks can `terragrunt init` cleanly. Once internal modules are
available they will be referenced via
`${include.root.locals.module_base_path}/<module>?ref=<tag>`.

Domain values (ACM certificate, Route53 zone) are not hardcoded in
`region.hcl` — stacks accept `var.domain_name` / `var.route53_zone_name`
and the caller supplies the real value via env.hcl or `TF_VAR_*`.

## Deployment

Use Terragrunt commands to deploy infrastructure. Note: the `*-all`
shortcuts (`plan-all`, `apply-all`, `destroy-all`) were deprecated and
removed in modern Terragrunt; use `run-all <cmd>` instead.

```bash
# Plan all stacks in dev
cd dev/us-east-1 && terragrunt run-all plan

# Apply all stacks in dev
cd dev/us-east-1 && terragrunt run-all apply

# Destroy (use with care)
cd dev/us-east-1 && terragrunt run-all destroy

# Plan a single stack
cd dev/us-east-1/vpc && terragrunt plan
```

Or use the Makefile helpers:

```bash
make plan ENV=dev REGION=us-east-1 SERVICE=vpc
make apply ENV=dev REGION=us-east-1 SERVICE=vpc
make validate    # run-all validate across dev/stage/prod
```

## Prerequisites

1. AWS CLI configured (or assumed role via OIDC for CI).
2. Terraform `>= 1.9, < 2.0` (CI pins `1.15.1`).
3. Terragrunt `>= 1.0` (CI pins `1.0.3`).
4. AWS permissions sufficient to create the resources in question.

## Cloning

```bash
git clone https://github.com/melorga/infra-live.git
```

## Recent changes

- **Terragrunt `0.67.16` -> `1.0.3`** — root `terragrunt_version_constraint`
  bumped to `>= 1.0`. Terragrunt 1.0 introduced breaking changes (CAS,
  hcl fmt, experiments). See the
  [migration guide](https://terragrunt.gruntwork.io/docs/migrate/migrating-from-0xx/).
- **Terraform `1.9.8` -> `1.15.1`** — within the existing
  `>= 1.9, < 2.0` constraint; CI pin updated.
- **`terraform-aws-modules/vpc/aws` `5.21.0` -> `6.6.1`** — major bump,
  applied across dev/stage/prod. See
  [UPGRADE-6.0.md](https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/UPGRADE-6.0.md).
- **`terraform-aws-modules/rds/aws` `6.10.0` -> `7.2.0`** — major bump
  (highest-risk change in this repo). See the
  [v7.0.0 release notes](https://github.com/terraform-aws-modules/terraform-aws-rds/releases/tag/v7.0.0).
- **`terraform-aws-modules/eks/aws` `21.0.0` -> `21.19.0`** — patch bump
  within the v21 major.
- **`actions/checkout` `v4` -> `v6`** in the live workflow.
