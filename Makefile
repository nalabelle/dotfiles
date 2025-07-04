SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

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
.PHONY: test-workflows
test-workflows: ## Runs GitHub Actions tests for Darwin and Home configurations
	./test/test-workflows

.PHONY: test
test: ## Test configurations appropriate for current OS (mirrors CI workflow)
	@echo "Testing configurations for $(shell uname -s)..."
	@if [[ "$(shell uname -s)" == "Darwin" ]]; then \
		echo "Testing Darwin configurations..."; \
		nix build .#darwinConfigurations.tennyson.system; \
		nix build .#darwinConfigurations.bst.system; \
		nix build .#homeConfigurations."nalabelle@darwin".activationPackage; \
	else \
		echo "Testing Linux home configurations..."; \
		nix build '.#homeConfigurations."nalabelle@twain".activationPackage'; \
	fi
	@echo "All tests completed successfully!"

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
