# Development environment configuration
locals {
  environment  = "dev"
  project_name = "portfolio-demo"
}

inputs = {
  environment  = local.environment
  project_name = local.project_name

  # Development-specific settings
  instance_types = ["t3.micro", "t3.small"]
  min_capacity   = 1
  max_capacity   = 2

  # Backup and retention settings
  backup_retention_days = 1
  log_retention_days    = 7

  # Security settings
  enable_deletion_protection = false
  enable_backup              = false
  enable_monitoring          = false

  # Cost optimization
  enable_spot_instances = true
  storage_class         = "STANDARD_IA"
}
