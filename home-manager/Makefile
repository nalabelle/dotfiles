.PHONY: test
test:
	# Does a test build of a system and home config
	nix flake check
	nix build .#darwinConfigurations.tennyson.system
	nix build .#homeConfigurations."nalabelle@tennyson".activationPackage

.PHONY: clean
clean:
	rm -rf result


.PHONY: switch
switch:
	./bin/nix-refresh