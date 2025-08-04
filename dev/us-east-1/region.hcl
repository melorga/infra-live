# US East 1 region configuration
locals {
  aws_region = "us-east-1"
}

inputs = {
  aws_region = local.aws_region

  # Region-specific settings
  availability_zones = ["us-east-1a", "us-east-1b"]

  # Networking
  vpc_cidr = "10.10.0.0/16"

  # Regional costs and features
  nat_gateway_per_az = false
  enable_flow_logs   = true

  # Certificate and DNS
  acm_certificate_domain = "*.yourdomain.com"
  route53_zone_name      = "yourdomain.com"
}
