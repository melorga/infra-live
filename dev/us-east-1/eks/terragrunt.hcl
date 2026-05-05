# EKS Terragrunt configuration
#
# Source: public registry module. When melorga/iac-modules ships a
# first-party eks module, swap to:
#   source = "${include.root.locals.module_base_path}/eks?ref=<tag>"
terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=21.0.0"
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

# EKS depends on VPC for subnet ids
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id          = "vpc-mock"
    private_subnets = ["subnet-mock-1", "subnet-mock-2"]
    public_subnets  = ["subnet-mock-public-1", "subnet-mock-public-2"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

inputs = {
  # Cluster basics
  name               = "${include.env.locals.env_vars.name_prefix}-eks"
  kubernetes_version = "1.30"

  # Networking
  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.private_subnets

  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"] # tighten in prod via separate inputs

  enabled_log_types                      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = include.env.locals.monitoring.log_retention_days

  # Encryption
  encryption_config = {
    resources = ["secrets"]
  }

  # IRSA
  enable_irsa = true

  # Managed node groups
  eks_managed_node_groups = {
    main = {
      instance_types = [include.env.locals.instance_types.eks_node_type]
      capacity_type  = "ON_DEMAND"

      min_size     = include.env.locals.scaling.eks_min_size
      max_size     = include.env.locals.scaling.eks_max_size
      desired_size = include.env.locals.scaling.eks_desired_size

      ami_type = "AL2023_x86_64_STANDARD"

      labels = {
        Environment = include.env.locals.environment
        NodeGroup   = "main"
      }
    }
  }

  # Add-ons
  addons = {
    coredns                = { most_recent = true }
    kube-proxy             = { most_recent = true }
    vpc-cni                = { most_recent = true, before_compute = true }
    aws-ebs-csi-driver     = { most_recent = true }
  }
}
