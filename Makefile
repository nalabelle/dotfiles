.PHONY: test
test:
	# Does a test build of a system and home config
	nix flake check
	nix build .#darwinConfigurations.tennyson.system
	nix build .#homeConfigurations.nalabelle.activationPackage

.PHONY: clean
clean:
	rm -rf result


.PHONY: switch
switch:
	./bin/nix-refresh

.PHONY: update
update:
	nix flake update

.PHONY: gc
gc:
	nix-collect-garbage --delete-old
