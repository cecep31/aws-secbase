ENV       ?= prod
ENV_DIR   := environments/$(ENV)
MODULES   := $(wildcard modules/*)
TESTED    := modules/secure-bucket modules/alerting

.PHONY: help fmt fmt-check validate test lint scan init plan apply bootstrap ci

help: ## Show targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-12s %s\n", $$1, $$2}'

fmt: ## Format all code
	tofu fmt -recursive

fmt-check: ## Fail if code is not formatted
	tofu fmt -recursive -check -diff

validate: ## Validate every module and environment without a backend
	@for d in $(MODULES) bootstrap $(ENV_DIR); do \
		echo "==> $$d"; \
		tofu -chdir=$$d init -backend=false -input=false >/dev/null && tofu -chdir=$$d validate || exit 1; \
	done

test: ## Run offline unit tests (mock provider, no AWS credentials needed)
	@for d in $(TESTED); do \
		echo "==> $$d"; \
		tofu -chdir=$$d init -backend=false -input=false >/dev/null && tofu -chdir=$$d test || exit 1; \
	done

lint: ## Run tflint
	tflint --init && tflint --recursive --config=$(CURDIR)/.tflint.hcl

scan: ## Static security scan (trivy + checkov)
	trivy config --severity HIGH,CRITICAL --exit-code 1 .
	checkov -d . --framework terraform --quiet --compact

bootstrap: ## Create the state bucket and KMS key (needs TF_VAR_state_passphrase)
	tofu -chdir=bootstrap init && tofu -chdir=bootstrap apply

init: ## Init the environment with the remote backend
	tofu -chdir=$(ENV_DIR) init -backend-config=backend.hcl

plan: ## Plan the environment
	tofu -chdir=$(ENV_DIR) plan -out=tfplan

apply: ## Apply the saved plan
	tofu -chdir=$(ENV_DIR) apply tfplan

ci: fmt-check validate test ## Checks run in CI
