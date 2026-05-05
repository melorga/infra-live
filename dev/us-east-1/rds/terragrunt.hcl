# RDS Terragrunt configuration
#
# Source: public registry module. When melorga/iac-modules ships a
# first-party rds module, swap to:
#   source = "${include.root.locals.module_base_path}/rds?ref=<tag>"
terraform {
  source = "tfr:///terraform-aws-modules/rds/aws?version=6.10.0"
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

# RDS depends on VPC for the database subnet group
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                     = "vpc-mock"
    database_subnets           = ["subnet-mock-db-1", "subnet-mock-db-2"]
    database_subnet_group_name = "mock-db-subnet-group"
    private_subnets_cidr_blocks = ["10.10.11.0/24", "10.10.12.0/24"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

inputs = {
  identifier = "${include.env.locals.env_vars.name_prefix}-postgres"

  engine            = "postgres"
  engine_version    = "15.7"
  family            = "postgres15"
  major_engine_version = "15"
  instance_class    = include.env.locals.instance_types.rds_instance_class

  allocated_storage     = include.env.locals.storage.rds_allocated_storage
  max_allocated_storage = include.env.locals.storage.rds_allocated_storage * 2
  storage_type          = "gp3"
  storage_encrypted     = include.env.locals.storage.rds_storage_encrypted

  db_name  = "portfoliodb"
  username = "dbadmin"
  port     = 5432

  manage_master_user_password = true

  db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group_name
  create_db_subnet_group = false

  vpc_security_group_ids = []

  multi_az = false

  backup_retention_period = include.env.locals.backup.rds_backup_retention_period
  backup_window           = include.env.locals.backup.rds_backup_window
  maintenance_window      = include.env.locals.backup.rds_maintenance_window
  copy_tags_to_snapshot   = true

  deletion_protection      = include.env.locals.security.deletion_protection
  skip_final_snapshot      = !include.env.locals.security.deletion_protection
  final_snapshot_identifier_prefix = "${include.env.locals.env_vars.name_prefix}-final-snapshot"

  performance_insights_enabled = false
  monitoring_interval          = 0

  enabled_cloudwatch_logs_exports = ["postgresql"]
}
