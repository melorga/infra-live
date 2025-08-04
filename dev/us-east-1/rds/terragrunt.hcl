# RDS Terragrunt configuration

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

# Dependencies - RDS depends on VPC
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                     = "vpc-mock"
    database_subnets           = ["subnet-mock-db-1", "subnet-mock-db-2"]
    database_subnet_group_name = "mock-db-subnet-group"
    vpc_security_group_ids     = ["sg-mock"]
  }
}

# Terraform module source
terraform {
  source = "${include.root.locals.module_base_path}/rds"
}

# Input variables for the RDS module
inputs = {
  # Basic configuration
  identifier = "${include.env.locals.env_vars.name_prefix}-postgres"

  # Engine configuration
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = include.env.locals.env_vars.instance_types.rds_instance_class

  # Storage configuration
  allocated_storage     = include.env.locals.env_vars.storage.rds_allocated_storage
  max_allocated_storage = include.env.locals.env_vars.storage.rds_allocated_storage * 2
  storage_type          = "gp3"
  storage_encrypted     = include.env.locals.env_vars.storage.rds_storage_encrypted

  # Database configuration
  db_name  = "portfoliodb"
  username = "dbadmin"
  port     = 5432

  # Password will be managed by AWS Secrets Manager
  manage_master_user_password   = true
  master_user_secret_kms_key_id = null # Use default AWS managed key

  # Network configuration
  db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = [] # Will be created by the module

  # Create security group
  create_db_subnet_group = false # Use the one from VPC module

  # Security group configuration
  create_security_group      = true
  security_group_name        = "${include.env.locals.env_vars.name_prefix}-rds-sg"
  security_group_description = "Security group for ${include.env.locals.env_vars.name_prefix} RDS instance"

  # Security group rules
  ingress_cidr_blocks = [] # No direct CIDR access
  ingress_rules       = []

  # Custom ingress rules for EKS nodes
  ingress_with_source_security_group_id = [
    {
      description              = "PostgreSQL access from EKS nodes"
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = null # Will be populated by EKS module output
    }
  ]

  # High availability configuration
  multi_az = false # Single AZ for dev environment

  # Backup configuration
  backup_retention_period  = include.env.locals.env_vars.backup.rds_backup_retention_period
  backup_window            = include.env.locals.env_vars.backup.rds_backup_window
  copy_tags_to_snapshot    = true
  delete_automated_backups = true

  # Maintenance configuration
  maintenance_window         = include.env.locals.env_vars.backup.rds_maintenance_window
  auto_minor_version_upgrade = true

  # Deletion protection
  deletion_protection              = include.env.locals.env_vars.security.deletion_protection
  skip_final_snapshot              = !include.env.locals.env_vars.security.deletion_protection
  final_snapshot_identifier_prefix = "${include.env.locals.env_vars.name_prefix}-final-snapshot"

  # Monitoring configuration
  monitoring_interval = 0 # Disable enhanced monitoring for dev
  monitoring_role_arn = null

  # Performance Insights
  performance_insights_enabled = false # Disabled for dev environment

  # CloudWatch logs
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Parameters
  family = "postgres15"

  # Major version upgrade
  allow_major_version_upgrade = false

  # Character set (not applicable to PostgreSQL)
  character_set_name = null

  # Common tags will be inherited from root configuration
}
