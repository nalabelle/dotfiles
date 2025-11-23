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



.PHONY: test-linux
test-linux:
ifeq ($(shell uname), Linux)
	@echo "Testing Linux configurations..."
	nix build .#homeConfigurations."nalabelle@chandler".activationPackage
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
test: test-linux test-darwin ## Test configurations appropriate for current OS (mirrors CI workflow)
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

# Package home-manager configuration for distribution
package-home: artifacts/home-manager-config.tar.gz ## Package home-manager configuration as tar.gz

artifacts/home-manager-config.tar.gz: ## Build home-manager configuration package
	@echo "Building home-manager configuration..."
	nix build .#homeConfigurations.nalabelle.activationPackage
	@echo "Creating package..."
	sudo rm -rf artifacts || true
	mkdir -p artifacts
	# Copy actual files (dereference symlinks) and exclude home-path
	cp -rL result/home-files artifacts/home-files
	cp -rL result/LaunchAgents artifacts/LaunchAgents
	cp result/activate artifacts/
	# Create tarball
	cd artifacts && tar -czf home-manager-config.tar.gz home-files LaunchAgents activate
	@echo "Package created: artifacts/home-manager-config.tar.gz"
