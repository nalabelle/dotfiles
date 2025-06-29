# Default target to show help
.DEFAULT_GOAL := help

# Show this help message
.PHONY: help
help:
	@printf "Available targets:\n"
	@awk '/^[a-zA-Z0-9_-]+:.*?## / { \
		printf "  %-13s %s\n", substr($$1, 1, length($$1)-1), substr($$0, index($$0, "##") + 3) \
	}' $(MAKEFILE_LIST)

# Test build system and home configurations via GitHub Actions
.PHONY: test
test: ## Runs GitHub Actions tests for Darwin and Home configurations
	# Trigger workflows for Darwin and Home configs
	gh workflow run test-darwin.yml
	gh workflow run test-home.yml
	@echo "Waiting for workflows to start..."
	@sleep 10
	# Get latest run IDs for each workflow
	$(eval DARWIN_RUN := $(shell gh run list --workflow=test-darwin.yml --limit 1 --json databaseId --jq '.[0].databaseId'))
	$(eval HOME_RUN := $(shell gh run list --workflow=test-home.yml --limit 1 --json databaseId --jq '.[0].databaseId'))
	@echo "Watching test-darwin.yml (run ID: $(DARWIN_RUN))"
	gh run watch $(DARWIN_RUN) --exit-status || (echo "Darwin workflow failed. Check GitHub Actions for details."; exit 1)
	@echo "Watching test-home.yml (run ID: $(HOME_RUN))"
	gh run watch $(HOME_RUN) --exit-status || (echo "Home workflow failed. Check GitHub Actions for details."; exit 1)
	@echo "All workflows completed. Check GitHub Actions for results."

test-local: ## Quick local home test
	nix build .#homeConfigurations.nalabelle.activationPackage

# Remove build artifacts
.PHONY: clean
clean: ## Clean up build results
	rm -rf result

# Switch darwin configuration for current host
.PHONY: darwin-switch
darwin-switch: ## Update system configuration
	sudo darwin-rebuild switch --flake .#$(shell hostname)

# Switch home-manager configuration
.PHONY: home-switch
home-switch: ## Update home configuration
	home-manager switch --flake .

# Update nix flake dependencies
.PHONY: update
update: ## Update dependencies
	nix flake update


# Run garbage collection
.PHONY: gc
gc: ## Clean up old packages
	nix-collect-garbage --delete-old
