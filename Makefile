# Default target to show help
.DEFAULT_GOAL := help

# Show this help message
.PHONY: help
help:
	@printf "Available targets:\n"
	@awk '/^[a-zA-Z0-9_-]+:.*?## / { \
		printf "  %-13s %s\n", substr($$1, 1, length($$1)-1), substr($$0, index($$0, "##") + 3) \
	}' $(MAKEFILE_LIST)

# Test build system and home configurations
.PHONY: test
test: ## Runs test builds
	# Does a test build of a system and home config
	nix build .#darwinConfigurations.tennyson.system
	nix build .#darwinConfigurations.bst.system
	nix build .#homeConfigurations.nalabelle.activationPackage
	nix build .#homeConfigurations."nalabelle@bst".activationPackage

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

.PHONY: test-linux
test-linux:
	# Test Linux deployment of Kilo Code configurations via Docker multi-stage build
	# Verification runs automatically during build - build fails if verification fails
	docker build -f test/Dockerfile -t dotfiles-test . --target verify

# Run garbage collection
.PHONY: gc
gc: ## Clean up old packages
	nix-collect-garbage --delete-old
