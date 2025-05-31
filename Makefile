.PHONY: test
test:
	# Does a test build of a system and home config
	nix flake check
	nix build .#darwinConfigurations.tennyson.system
	nix build .#homeConfigurations.nalabelle.activationPackage

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

.PHONY: gc
gc:
	nix-collect-garbage --delete-old
