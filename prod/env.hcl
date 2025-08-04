# Production environment configuration
locals {
  environment  = "prod"
  project_name = "portfolio-demo"
}

inputs = {
  environment  = local.environment
  project_name = local.project_name

  # Production-specific settings
  instance_types = ["t3.medium", "t3.large"]
  min_capacity   = 2
  max_capacity   = 10

  # Backup and retention settings
  backup_retention_days = 30
  log_retention_days    = 90

  # Security settings
  enable_deletion_protection = true
  enable_backup              = true
  enable_monitoring          = true

  # Cost optimization
  enable_spot_instances = false
  storage_class         = "STANDARD"
}
