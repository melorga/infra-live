# VPC infrastructure for dev us-east-1
terraform {
  source = "git::ssh://git@github.com/melorga-portfolio/iac-modules.git//modules/vpc-network?ref=v1.0.0"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  vpc_name = "dev-vpc"
  vpc_cidr = "10.10.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true # Single NAT for dev cost savings
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_logs             = true
  flow_logs_destination_type   = "cloud-watch-logs"
  flow_logs_log_retention_days = 7
}
