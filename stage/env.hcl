# Staging environment configuration
locals {
  environment  = "stage"
  project_name = "portfolio-demo"
}

inputs = {
  environment  = local.environment
  project_name = local.project_name

  # Staging-specific settings
  instance_types = ["t3.small", "t3.medium"]
  min_capacity   = 1
  max_capacity   = 3

  # Backup and retention settings
  backup_retention_days = 7
  log_retention_days    = 30

  # Security settings
  enable_deletion_protection = false
  enable_backup              = true
  enable_monitoring          = true

  # Cost optimization
  enable_spot_instances = true
  storage_class         = "STANDARD_IA"
}
