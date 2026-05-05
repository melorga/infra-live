.DEFAULT_GOAL := help
.PHONY: help init plan apply destroy validate format clean clean-plans \
        plan-dev plan-stage plan-prod apply-dev apply-stage apply-prod \
        validate-dev validate-stage validate-prod

# Variables
ENV ?= dev
REGION ?= us-east-1
SERVICE ?= vpc

help: ## Show this help message
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ----- single-stack targets -----

init: ## Initialize a single stack: ENV/REGION/SERVICE
	cd $(ENV)/$(REGION)/$(SERVICE) && terragrunt init

plan: ## Plan a single stack: ENV/REGION/SERVICE
	cd $(ENV)/$(REGION)/$(SERVICE) && terragrunt plan

apply: ## Apply a single stack: ENV/REGION/SERVICE
	cd $(ENV)/$(REGION)/$(SERVICE) && terragrunt apply

destroy: ## Destroy a single stack: ENV/REGION/SERVICE
	cd $(ENV)/$(REGION)/$(SERVICE) && terragrunt destroy

# ----- whole-tree targets (run-all replaces deprecated *-all) -----

validate: ## Validate every stack in dev/stage/prod
	@for env in dev stage prod; do \
	  echo "==> $$env"; \
	  (cd $$env && terragrunt run-all validate) || exit 1; \
	done

plan-dev: ## run-all plan for dev/$(REGION)
	cd dev/$(REGION) && terragrunt run-all plan

plan-stage: ## run-all plan for stage/$(REGION)
	cd stage/$(REGION) && terragrunt run-all plan

plan-prod: ## run-all plan for prod/$(REGION)
	cd prod/$(REGION) && terragrunt run-all plan

apply-dev: ## run-all apply for dev/$(REGION)
	cd dev/$(REGION) && terragrunt run-all apply

apply-stage: ## run-all apply for stage/$(REGION)
	cd stage/$(REGION) && terragrunt run-all apply

apply-prod: ## run-all apply for prod/$(REGION)
	cd prod/$(REGION) && terragrunt run-all apply

validate-dev: ## run-all validate for dev/$(REGION)
	cd dev/$(REGION) && terragrunt run-all validate

validate-stage: ## run-all validate for stage/$(REGION)
	cd stage/$(REGION) && terragrunt run-all validate

validate-prod: ## run-all validate for prod/$(REGION)
	cd prod/$(REGION) && terragrunt run-all validate

# ----- formatting & cleanup -----

format: ## Format all .hcl files
	terragrunt hclfmt

clean: ## Remove all .terragrunt-cache directories
	find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

clean-plans: ## Remove all plan files
	find . -name "*.tfplan" -delete
