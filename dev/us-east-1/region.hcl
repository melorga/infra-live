# us-east-1 region configuration (dev)
locals {
  aws_region = "us-east-1"
}

inputs = {
  aws_region = local.aws_region

  availability_zones = ["us-east-1a", "us-east-1b"]

  vpc_cidr = "10.10.0.0/16"

  nat_gateway_per_az = false
  enable_flow_logs   = true

  # Domain/zone are intentionally not hardcoded here. Components that need
  # ACM/Route53 should accept `var.domain_name` / `var.route53_zone_name`
  # and have the caller supply real values via env.hcl or TF_VAR_*.
}
