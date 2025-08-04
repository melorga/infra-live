.DEFAULT_GOAL := help
.PHONY: help init plan apply destroy validate format

# Variables
ENV ?= dev
REGION ?= us-east-1
SERVICE ?= network

# Help target
help: ## Show this help message
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terragrunt for specified environment/region/service
	@echo "Initializing $(ENV)/$(REGION)/$(SERVICE)..."
	cd $(ENV)/$(REGION)/$(SERVICE) && terragrunt init

plan: ## Plan Terragrunt for specified environment/region/service
	@echo "Planning $(ENV)/$(REGION)/$(SERVICE)..."
	cd $(ENV)/$(REGION)/$(SERVICE) && terragrunt plan

apply: ## Apply Terragrunt for specified environment/region/service
	@echo "Applying $(ENV)/$(REGION)/$(SERVICE)..."
	cd $(ENV)/$(REGION)/$(SERVICE) && terragrunt apply

destroy: ## Destroy Terragrunt for specified environment/region/service
	@echo "Destroying $(ENV)/$(REGION)/$(SERVICE)..."
	cd $(ENV)/$(REGION)/$(SERVICE) && terragrunt destroy

validate: ## Validate all Terragrunt configurations
	@echo "Validating all configurations..."
	terragrunt validate-all

format: ## Format all Terragrunt files
	@echo "Formatting all .hcl files..."
	terragrunt hclfmt

plan-all: ## Plan all environments
	@echo "Planning all environments..."
	terragrunt plan-all

# Environment-specific targets
plan-prod: ## Plan production environment
	$(MAKE) ENV=prod REGION=us-east-1 plan-all

plan-stage: ## Plan staging environment
	$(MAKE) ENV=stage REGION=us-east-1 plan-all

# Quick deployment targets
deploy-network: ## Deploy network infrastructure
	$(MAKE) ENV=$(ENV) REGION=$(REGION) SERVICE=network apply

deploy-compute: ## Deploy compute infrastructure
	$(MAKE) ENV=$(ENV) REGION=$(REGION) SERVICE=compute apply

# Cleanup targets
clean: ## Remove .terragrunt-cache directories
	find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

clean-plans: ## Remove all plan files
	find . -name "*.tfplan" -delete
