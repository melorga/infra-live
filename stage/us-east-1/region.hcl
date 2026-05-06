# us-east-1 region configuration (stage)
locals {
  aws_region = "us-east-1"
}

inputs = {
  aws_region = local.aws_region

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  vpc_cidr = "10.20.0.0/16"

  nat_gateway_per_az = false
  enable_flow_logs   = true

  # See dev/us-east-1/region.hcl: domain_name / route53_zone_name come
  # from var.* values, not from this file.
}
