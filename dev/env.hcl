# Development environment configuration
#
# Component terragrunt.hcl files reference these grouped maps via
# `include.env.locals.<group>.<key>`, so the structure of `locals`
# below is part of the public contract with components.
locals {
  environment  = "dev"
  project_name = "melorga-portfolio"

  env_vars = {
    name_prefix = "melorga-dev"
  }

  instance_types = {
    eks_node_type      = "t3.medium"
    rds_instance_class = "db.t3.medium"
  }

  scaling = {
    eks_min_size     = 1
    eks_max_size     = 3
    eks_desired_size = 2
  }

  monitoring = {
    log_retention_days = 7
    enable_monitoring  = false
  }

  storage = {
    rds_allocated_storage = 20
    rds_storage_encrypted = true
  }

  backup = {
    rds_backup_window            = "03:00-04:00"
    rds_maintenance_window       = "sun:04:00-sun:05:00"
    rds_backup_retention_period  = 7
    backup_retention_days        = 7
    enable_backup                = false
  }

  security = {
    deletion_protection = false
  }

  cost = {
    enable_spot_instances = true
    storage_class         = "STANDARD_IA"
  }
}

inputs = {
  environment  = local.environment
  project_name = local.project_name
  name_prefix  = local.env_vars.name_prefix
}
