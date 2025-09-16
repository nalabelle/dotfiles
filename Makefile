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


# Test JavaScript utilities
.PHONY: test-js
test-js: ## Test JavaScript utilities
	@echo "Testing JavaScript utilities..."
	@cd packages/merge-vscode-settings && nix shell nixpkgs#nodejs nixpkgs#nodePackages.npm --command bash -c "npm install && npm test"
	@echo "JavaScript tests completed successfully!"

.PHONY: test-linux
test-linux:
ifeq ($(shell uname), Linux)
	@echo "Testing Linux configurations..."
##	nix build '.#homeConfigurations."nalabelle@twain".activationPackage'
	nix build .#nixosConfigurations.twain.config.system.build.toplevel
	nix build .#nixosConfigurations.chandler.config.system.build.toplevel
else
	@echo "Skipping Linux targets on non-Linux system"
endif

.PHONY: test-darwin
test-darwin:
ifeq ($(shell uname), Darwin)
	@echo "Testing Darwin configurations..."
	nix build .#darwinConfigurations.tennyson.system
	nix build .#homeConfigurations."nalabelle@darwin".activationPackage
else
	@echo "Skipping Darwin targets on non-Darwin system"
endif

.PHONY: test
test: test-linux test-darwin test-js ## Test configurations appropriate for current OS (mirrors CI workflow)
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

# Set up 1Password service account token for opnix
.PHONY: opnix-token-set
opnix-token-set: ## Set up 1Password service account token for opnix
	@echo "Setting up opnix service account token..."
	sudo -E nix run github:brizzbuzz/opnix -- token set
	sudo chmod 640 /etc/opnix-token
ifeq ($(shell uname), Darwin)
	sudo chown root:staff /etc/opnix-token
endif
ifeq ($(shell uname), Linux)
	sudo chown root:users /etc/opnix-token
endif

	# Verify permissions
	ls -la /etc/opnix-token
	# Should show: -rw-r----- 1 root onepassword-secrets
