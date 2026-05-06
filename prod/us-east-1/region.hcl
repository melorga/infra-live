# us-east-1 region configuration (prod)
locals {
  aws_region = "us-east-1"
}

inputs = {
  aws_region = local.aws_region

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  vpc_cidr = "10.0.0.0/16"

  nat_gateway_per_az = true
  enable_flow_logs   = true

  # Domain/zone come from var.* values supplied by the caller.
}
