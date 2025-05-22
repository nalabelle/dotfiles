{ inputs, ... }:
let
  systems = [ "aarch64-darwin" "x86_64-linux" ];
  lib = inputs.nixpkgs.lib;
  username = "nalabelle";
  nixpkgsConfig = { allowUnfree = true; };

  # Create a darwin configuration for a host
  mkDarwinSystem = { hostname }:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ../nix/nixos.nix
        ../nix/darwin.nix
        ../hosts/${hostname}/darwin-configuration.nix
      ];
      specialArgs = { inherit inputs username hostname; };
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
      hostHomeConfigs = lib.listToAttrs (lib.filter (x: x != null) (map
        (hostname:
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
          } else
            null) hosts));

      genericConfigs = lib.listToAttrs (map (system: {
        name = "${username}";
        value = mkHomeConfig {
          # hostname is unused in the home configs, a string that shouldn't match any hosts files/dirs
          hostname = "default";
          inherit system;
        };
      }) systems);

      homeConfigs = hostHomeConfigs // genericConfigs;

    in {
      darwinConfigurations = darwinConfigs;
      homeConfigurations = homeConfigs;
    };
}
