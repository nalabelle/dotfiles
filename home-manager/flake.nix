{
  description = "Nix configuration for dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mkAlias = {
      url = "github:cdmistman/mkAlias";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, home-manager, nixpkgs, darwin, mkAlias, ... }:
    let
      vars = { username = "nalabelle"; }; # Assuming username is consistent

      # Helper function to create a configured pkgs instance for Home Manager
      mkHomeManagerPkgs = system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          # You could add common overlays for Home Manager pkgs here if needed
          # overlays = [ ... ];
        };

      # Define Home Manager configuration for aarch64-darwin
      darwinHomeModules = home-manager.lib.homeManagerConfiguration {
        pkgs = mkHomeManagerPkgs "aarch64-darwin"; # Use the helper
        extraSpecialArgs = {
          inherit vars inputs; # Pass username and flake inputs
          system = "aarch64-darwin";
          # hostname can be set here if needed by modules, or derived within modules
        };
        # Your modules path, assuming modules/default.nix sets home.homeDirectory conditionally
        modules = [ ./modules ./modules/systems/darwin ];
      };

      # Define Home Manager configuration for x86_64-linux
      linuxHomeModules = home-manager.lib.homeManagerConfiguration {
        pkgs = mkHomeManagerPkgs "x86_64-linux"; # Use the helper
        extraSpecialArgs = {
          inherit vars inputs; # Pass username and flake inputs
          system = "x86_64-linux";
        };
        modules = [ ./modules ];
      };

    in {
      # Darwin configurations (for Nix-Darwin system build)
      # This part remains, assuming ./darwin/default.nix correctly integrates Home Manager
      # for the Nix-Darwin system build (e.g., for 'tennyson').
      # It might use one of the home manager configurations defined above, or define its own.
      darwinConfigurations = (import ./darwin {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager darwin mkAlias vars;
        # If ./darwin/default.nix needs to refer to the home manager config:
        homeManagerConfiguration = darwinHomeModules;
      });

      # Expose Home Manager configurations under legacyPackages for `home-manager switch`
      # This allows a bare `home-manager switch` to find the config for the current system.
      legacyPackages.aarch64-darwin.homeConfigurations."${vars.username}" =
        darwinHomeModules;
      legacyPackages.x86_64-linux.homeConfigurations."${vars.username}" =
        linuxHomeModules;

      # You can also provide named configurations for explicit targeting if desired,
      # though the legacyPackages structure above is often sufficient for `home-manager switch`.
      # Example:
      # homeConfigurations = {
      #   "nalabelle-darwin" = darwinHomeModules;
      #   "nalabelle-linux" = linuxHomeModules;
      # };
    };
}
