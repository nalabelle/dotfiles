.PHONY: test
test:
	# Does a test build of a system and home config
	nix build .#darwinConfigurations.tennyson.system 
	nix build .#homeConfigurations."nalabelle".activationPackage

.PHONY: clean
clean:
	rm -rf result


.PHONY: switch
switch:
	sudo darwin-rebuild switch --flake .
	home-manager switch --flake .