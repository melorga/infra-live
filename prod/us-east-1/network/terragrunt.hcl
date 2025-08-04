# Network infrastructure for production us-east-1
terraform {
  source = "git::ssh://git@github.com/melorga-portfolio/iac-modules.git//modules/vpc-network?ref=v1.0.0"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  vpc_name = "${local.environment}-vpc"
  vpc_cidr = "10.0.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_logs             = true
  flow_logs_destination_type   = "cloud-watch-logs"
  flow_logs_log_retention_days = 14
}
