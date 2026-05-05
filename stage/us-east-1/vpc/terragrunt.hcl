# VPC infrastructure for stage us-east-1
#
# Source: public registry module. When melorga/iac-modules ships a
# first-party vpc-network module, swap to:
#   source = "${include.root.locals.module_base_path}/vpc-network?ref=<tag>"
#
# v6 introduced breaking changes — see https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/UPGRADE-6.0.md
# TODO(audit): review v5 -> v6 upgrade guide for any input renames beyond the common ones in use here.
terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=6.6.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

include "region" {
  path   = find_in_parent_folders("region.hcl")
  expose = true
}

inputs = {
  name = "${include.env.locals.env_vars.name_prefix}-vpc"
  cidr = "10.20.0.0/16"

  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets   = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  private_subnets  = ["10.20.11.0/24", "10.20.12.0/24", "10.20.13.0/24"]
  database_subnets = ["10.20.21.0/24", "10.20.22.0/24", "10.20.23.0/24"]

  create_database_subnet_group = true

  enable_nat_gateway   = true
  single_nat_gateway   = true # cost savings for non-prod
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  flow_log_cloudwatch_log_group_retention_in_days = include.env.locals.monitoring.log_retention_days
}
