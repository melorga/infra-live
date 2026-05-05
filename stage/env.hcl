# Staging environment configuration
locals {
  environment  = "stage"
  project_name = "melorga-portfolio"

  env_vars = {
    name_prefix = "melorga-stage"
  }

  instance_types = {
    eks_node_type      = "t3.medium"
    rds_instance_class = "db.t3.medium"
  }

  scaling = {
    eks_min_size     = 2
    eks_max_size     = 4
    eks_desired_size = 2
  }

  monitoring = {
    log_retention_days = 30
    enable_monitoring  = true
  }

  storage = {
    rds_allocated_storage = 50
    rds_storage_encrypted = true
  }

  backup = {
    rds_backup_window            = "03:00-04:00"
    rds_maintenance_window       = "sun:04:00-sun:05:00"
    rds_backup_retention_period  = 14
    backup_retention_days        = 14
    enable_backup                = true
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
