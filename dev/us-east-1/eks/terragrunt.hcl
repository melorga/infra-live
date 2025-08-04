# EKS Terragrunt configuration

# Include root terragrunt configuration
include "root" {
  path = find_in_parent_folders()
}

# Include environment configuration
include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

# Include region configuration
include "region" {
  path   = find_in_parent_folders("region.hcl")
  expose = true
}

# Dependencies - EKS depends on VPC
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id          = "vpc-mock"
    private_subnets = ["subnet-mock-1", "subnet-mock-2"]
    public_subnets  = ["subnet-mock-public-1", "subnet-mock-public-2"]
  }
}

# Terraform module source
terraform {
  source = "${include.root.locals.module_base_path}/eks"
}

# Input variables for the EKS module
inputs = {
  # Basic configuration
  cluster_name    = "${include.env.locals.env_vars.name_prefix}-eks"
  cluster_version = "1.28"

  # VPC Configuration
  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.private_subnets

  # Cluster endpoint configuration
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # Restrict in production

  # Cluster logging
  cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = include.env.locals.env_vars.monitoring.log_retention_days

  # Node groups configuration
  eks_managed_node_groups = {
    main = {
      # Instance configuration
      instance_types = [include.env.locals.env_vars.instance_types.eks_node_type]
      capacity_type  = "ON_DEMAND"

      # Scaling configuration
      min_size     = include.env.locals.env_vars.scaling.eks_min_size
      max_size     = include.env.locals.env_vars.scaling.eks_max_size
      desired_size = include.env.locals.env_vars.scaling.eks_desired_size

      # Launch template configuration
      create_launch_template = true
      launch_template_name   = "${include.env.locals.env_vars.name_prefix}-eks-node-template"

      # Storage configuration
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      # Networking
      subnet_ids = dependency.vpc.outputs.private_subnets

      # AMI configuration
      ami_type = "AL2_x86_64"

      # User data
      enable_bootstrap_user_data = true

      # Labels and taints
      labels = {
        Environment = include.env.locals.env_vars.environment
        NodeGroup   = "main"
      }

      # Security groups
      remote_access = {
        ec2_ssh_key               = null # Add key name if needed
        source_security_group_ids = []
      }

      # IAM role
      create_iam_role          = true
      iam_role_name            = "${include.env.locals.env_vars.name_prefix}-eks-node-group-role"
      iam_role_use_name_prefix = false
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  # Cluster security group
  create_cluster_security_group          = true
  cluster_security_group_name            = "${include.env.locals.env_vars.name_prefix}-eks-cluster-sg"
  cluster_security_group_use_name_prefix = false

  cluster_security_group_additional_rules = {
    ingress_nodes_443 = {
      description                = "Node groups to cluster API"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Node security group
  create_node_security_group          = true
  node_security_group_name            = "${include.env.locals.env_vars.name_prefix}-eks-node-sg"
  node_security_group_use_name_prefix = false

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_443 = {
      description                   = "Cluster API to node groups"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_kubelet = {
      description                   = "Cluster API to node kubelets"
      protocol                      = "tcp"
      from_port                     = 10250
      to_port                       = 10250
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # IAM role for service accounts (IRSA)
  enable_irsa = true

  # Cluster IAM role
  create_iam_role          = true
  iam_role_name            = "${include.env.locals.env_vars.name_prefix}-eks-cluster-role"
  iam_role_use_name_prefix = false

  # KMS key for envelope encryption
  create_kms_key                  = true
  kms_key_description             = "EKS cluster ${include.env.locals.env_vars.name_prefix} encryption key"
  kms_key_usage                   = "ENCRYPT_DECRYPT"
  kms_key_deletion_window_in_days = 7

  # Add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # Common tags will be inherited from root configuration
}
