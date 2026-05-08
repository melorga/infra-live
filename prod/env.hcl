# Production environment configuration
locals {
  environment  = "prod"
  project_name = "melorga-portfolio"

  env_vars = {
    name_prefix = "melorga-prod"
  }

  instance_types = {
    eks_node_type      = "m6i.large"
    rds_instance_class = "db.m6i.large"
  }

  scaling = {
    eks_min_size     = 3
    eks_max_size     = 5
    eks_desired_size = 3
  }

  monitoring = {
    log_retention_days = 90
    enable_monitoring  = true
  }

  storage = {
    rds_allocated_storage = 200
    rds_storage_encrypted = true
  }

  backup = {
    rds_backup_window           = "03:00-04:00"
    rds_maintenance_window      = "sun:04:00-sun:05:00"
    rds_backup_retention_period = 30
    backup_retention_days       = 30
    enable_backup               = true
  }

  security = {
    deletion_protection = true
  }

  cost = {
    enable_spot_instances = false
    storage_class         = "STANDARD"
  }
}

inputs = {
  environment  = local.environment
  project_name = local.project_name
  name_prefix  = local.env_vars.name_prefix
}
