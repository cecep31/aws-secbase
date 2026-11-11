ENV_DIR := environments/prod
MODULES := $(wildcard modules/*)
TESTED  := modules/secure-bucket modules/alerting

.PHONY: help fmt check bootstrap init plan apply

help: ## Show targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

fmt: ## Format all code
	tofu fmt -recursive

check: ## Offline checks: format, validate, unit tests (no AWS credentials needed)
	tofu fmt -recursive -check -diff
	@for d in $(MODULES) bootstrap $(ENV_DIR); do \
		echo "==> validate $$d"; \
		tofu -chdir=$$d init -backend=false -input=false >/dev/null && tofu -chdir=$$d validate || exit 1; \
	done
	@for d in $(TESTED); do \
		echo "==> test $$d"; \
		tofu -chdir=$$d test || exit 1; \
	done

bootstrap: ## Create the state bucket and KMS key (run once)
	tofu -chdir=bootstrap init && tofu -chdir=bootstrap apply

init: ## Init the environment with the remote backend
	tofu -chdir=$(ENV_DIR) init -backend-config=backend.hcl

plan: ## Plan the environment
	tofu -chdir=$(ENV_DIR) plan -out=tfplan

apply: ## Apply the saved plan
	tofu -chdir=$(ENV_DIR) apply tfplan
