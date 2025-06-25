.PHONY: test
test:
	# Does a test build of a system and home config
	nix build .#darwinConfigurations.tennyson.system
	nix build .#darwinConfigurations.bst.system
	nix build .#homeConfigurations.nalabelle.activationPackage
	nix build .#homeConfigurations."nalabelle@bst".activationPackage

.PHONY: clean
clean:
	rm -rf result

.PHONY: darwin-switch
darwin-switch:
	sudo darwin-rebuild switch --flake .#$(shell hostname)

.PHONY: home-switch
home-switch:
	home-manager switch --flake .

.PHONY: update
update:
	nix flake update

.PHONY: test-linux
test-linux:
	# Test Linux deployment of Kilo Code configurations via Docker multi-stage build
	# Verification runs automatically during build - build fails if verification fails
	docker build -f test/Dockerfile -t dotfiles-test . --target verify

.PHONY: gc
gc:
	nix-collect-garbage --delete-old
