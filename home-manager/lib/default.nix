{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  username = "nalabelle"; # Hardcoded since it's always the same
  nixpkgsConfig = { allowUnfree = true; }; # Default config

  # Create a darwin configuration for a host
  mkDarwinSystem = { hostname, system ? "aarch64-darwin" }:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        inputs.home-manager.darwinModules.home-manager
        {
          nixpkgs.config = nixpkgsConfig;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = {
              imports = [
                (if builtins.pathExists
                ../hosts/${hostname}/home-configuration.nix then
                  ../hosts/${hostname}/home-configuration.nix
                else
                  { })
                ../home
              ];
            };
            extraSpecialArgs = { inherit inputs; };
          };
        }
        ../nix/nixos.nix
        ../nix/darwin.nix
        ../hosts/${hostname}/darwin-configuration.nix
      ];
      specialArgs = {
        inherit inputs;
        hostname = hostname;
        username = username;
      };
    };

  # Create a standalone home configuration
  mkHomeConfig = { hostname, system }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      };
      modules = [
        {
          home.username = username;
          home.homeDirectory = if system == "aarch64-darwin" then
            "/Users/${username}"
          else
            "/home/${username}";
        }
        ../home
        (if builtins.pathExists ../hosts/${hostname}/home-configuration.nix then
          ../hosts/${hostname}/home-configuration.nix
        else
          { })
      ];
      extraSpecialArgs = { inherit inputs; };
    };

in {
  __functor = _: _args:
    let
      # We'll use the default nixpkgsConfig defined at the top level
      # and the inputs from the outer scope
      # Get all hosts from the hosts directory
      hostsDir = ../hosts;
      entries = builtins.readDir hostsDir;
      hosts = builtins.attrNames
        (lib.filterAttrs (_: type: type == "directory") entries);

      # Create darwin configurations for hosts with darwin-configuration.nix
      darwinConfigs = lib.listToAttrs (lib.filter (x: x != null) (map (hostname:
        if builtins.pathExists
        ../hosts/${hostname}/darwin-configuration.nix then {
          name = hostname;
          value = mkDarwinSystem { inherit hostname; };
        } else
          null) hosts));

      # Create home configurations for all hosts with home-configuration.nix
      homeConfigs = lib.listToAttrs (lib.filter (x: x != null) (map (hostname:
        if builtins.pathExists
        ../hosts/${hostname}/home-configuration.nix then {
          name = "${username}@${hostname}";
          value = mkHomeConfig {
            inherit hostname;
            system = if builtins.pathExists
            ../hosts/${hostname}/darwin-configuration.nix then
              "aarch64-darwin"
            else
              "x86_64-linux";
          };
        } else {
          name = "${username}";
          value = mkHomeConfig {
            inherit hostname;
            system = if builtins.pathExists
            ../hosts/${hostname}/darwin-configuration.nix then
              "aarch64-darwin"
            else
              "x86_64-linux";
          };
        }) hosts));

    in {
      darwinConfigurations = darwinConfigs;
      homeConfigurations = homeConfigs;
    };
}
